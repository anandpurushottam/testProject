var express = require('express')
var app = express()



function convertVideo(name) {
  var exec = require('child_process').exec;
  var myscript = exec('./converter.sh ' + name);
  myscript.stdout.on('data', function (data) {
    console.log(data); // process output will be displayed here

  });
  myscript.stderr.on('data', function (data) {
    console.log(data); // process error output will be displayed here

  });


}



app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})


app.get('/', function (req, res) {
  res.send('hello world')
})


app.get('/api/converter', function (req, res) {
  var name = req.param('name');
  if (name != null) {
    res.send(name);
    convertVideo(name);
  } else {
    res.send("invalid input");
  }

});