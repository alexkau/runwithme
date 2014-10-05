
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// Parse.Cloud.define("hello", function(request, response) {
//   response.success("Hello world!");
// });

// Parse.Cloud.define("testUsers", function(request, response) {
//   var users = [
//     { "id": "person1", "location": new Parse.GeoPoint(42.3621656, -71.0799907), "runs": [{"length": 2, "time": 20}, {"length": 2.5, "time": 22}]},
//     { "id": "person2", "location": new Parse.GeoPoint(42.3621600, -71.0799001), "runs": [{"length": 2, "time": 40}, {"length": 1, "time": 15}]}
//   ];
//   response.success(users);
// });

function getAveragePace(user) {
  var runs = user.get("runs");
  if (runs.length == 0) {
    return -1;
  }

  var paces = [];
  for (var i=0; i < runs.length; i++) {
    paces.push(runs[i]["time"] / runs[i]["distance"]);
  }

  var sum = 0;
  for (var i=0; i < paces.length; i++) {
    sum += paces[i];
  }
  return sum / paces.length;
}

Parse.Cloud.define("usersNearMe", function(request, response) {
  // Get requesting user
  var query = new Parse.Query("User");
  var requestor;
  query.equalTo("username", request.params.username);
  query.find({

    success: function(result) {
      requestor = result[0];

      res = []
      starred = new Parse.Query("User");
      starred = new Parse.Query("User");
      starred.notEqualTo("username", requestor.get("username"));
      starred.containedIn("username", requestor.get("starred"));
      // might filter too much?
      starred.near("location", requestor.get("location"));
      starred.find({
        success: function(results) {
          for (var i=0; i < results.length; i++) {
            res.push({"fbusername": results[i].get("fbusername"), "distance": results[i].get("location").milesTo(requestor.get("location")), "starred": 1});
          }
        },
        error: function() {

        }
      });

      q2 = new Parse.Query("User");
      // All users except requesting user
      q2.notEqualTo("username", request.params.username);
      // Order by distance to requestor location
      starred.notContainedIn("username", requestor.get("starred"));
      q2.withinMiles("location", requestor.get("location"), 5);
      q2.find({
        success: function(results) {
          var requestorAveragePace = getAveragePace(requestor);
          for (var i=0; i < results.length; i++) {
            // Add to list if they're within 25% of our pace
            var averagePace = getAveragePace(results[i]);
            if (averagePace == -1 || requestorAveragePace == -1 || (averagePace <= requestorAveragePace * 1.25 && averagePace >= requestorAveragePace * 0.75)) {
              res.push({"fbusername": results[i].get("fbusername"), "distance": results[i].get("location").milesTo(requestor.get("location")), "starred": 0});
            } else {
              //res.push("skipped: " + averagePace + " vs " + requestorAveragePace);
            }
          }
          // res.push({"username": results[0].get("username"), "distance": results[0].get("location").milesTo(requestor.get("location"))});
          response.success(res);
        },
        error: function() {
          response.error("No users to return")
        }
      });
    },

    error: function() {
      response.error("Bad username")
    }
  });
});