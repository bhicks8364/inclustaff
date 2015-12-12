function myFunction() {
    document.getElementById("demo").innerHTML = "Paragraph changed.";
}
var current = gon.current;
function myFunction2() {
    document.getElementById("demo2").innerHTML = current.name;
}
function colorFunction() {
    document.getElementById("color").style.color = "red";
}
