function drawElapsedTimeGraph($drawArea, elapsedTimes, spot) {
  var gap = elapsedTimes.length - spot.length;
  for (var i = 0; i < gap; i++) {
    spot.unshift(undefined);
  }

  var excludeHyphenValue = function (arr) {
    return $.grep(arr, function (n, i) {
      return n !== '-';
    });
  };
  elapsedTimes = excludeHyphenValue(elapsedTimes);
  spot = excludeHyphenValue(spot);

  spot.splice(0, spot.length - elapsedTimes.length);

  var data = {
    labels: $.map(elapsedTimes, function () {
      return "";
    }),
    datasets: [
      {
        fillColor: "rgba(151,187,205,0.5)",
        strokeColor: "rgba(151,187,205,1)",
        pointColor: "rgba(151,187,205,1)",
        pointStrokeColor: "#fff",
        data: elapsedTimes
      },
      {
        pointColor: "rgba(220,122,109,1)",
        pointStrokeColor: "#fff",
        data: spot
      }
    ]
  };

  var maxVal = Math.ceil(Math.max.apply(null, elapsedTimes) / 100) * 100;

  var ctx = $drawArea.get(0).getContext("2d");
  var myNewChart = new Chart(ctx).Line(data, {
    pointDotRadius: 2.5,
    pointDotStrokeWidth: 0.5,
    animation: false,
    scaleOverride: true,
    scaleSteps: 10,
    scaleStepWidth: maxVal / 10,
    scaleStartValue: 0
  });
}

