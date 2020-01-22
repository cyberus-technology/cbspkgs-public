{ cbsLib }:

with cbsLib;


  #the empty set
  assert cartesian.cartesianProductFromSet {} == [ {} ];

  #a set with only one list
  assert cartesian.cartesianProductFromSet { a = [ 1 2 3 ];}
    == [ { a = 1; } { a = 2; } { a = 3; } ];

  #a set with lists of different lengths
  assert cartesian.cartesianProductFromSet {
    a = [ 1 ];
    b = [ 10 20 ];
  } == [
    { a = 1; b = 10; }
    { a = 1; b = 20; }
  ];

  #a set with a nonempty, and an empty list<Paste>
  assert cartesian.cartesianProductFromSet {
    a = [ ];
    b = [ 10 20 ];
  } == [ ];

  assert cartesian.cartesianProductFromSet {
    a = [ 1 2 3 ];
    b = [ 10 20 30 ];
    c = [ 100 200 300 ];
  } == [
    { a = 1; b = 10; c = 100; }
    { a = 1; b = 10; c = 200; }
    { a = 1; b = 10; c = 300; }

    { a = 1; b = 20; c = 100; }
    { a = 1; b = 20; c = 200; }
    { a = 1; b = 20; c = 300; }

    { a = 1; b = 30; c = 100; }
    { a = 1; b = 30; c = 200; }
    { a = 1; b = 30; c = 300; }

    { a = 2; b = 10; c = 100; }
    { a = 2; b = 10; c = 200; }
    { a = 2; b = 10; c = 300; }

    { a = 2; b = 20; c = 100; }
    { a = 2; b = 20; c = 200; }
    { a = 2; b = 20; c = 300; }

    { a = 2; b = 30; c = 100; }
    { a = 2; b = 30; c = 200; }
    { a = 2; b = 30; c = 300; }

    { a = 3; b = 10; c = 100; }
    { a = 3; b = 10; c = 200; }
    { a = 3; b = 10; c = 300; }

    { a = 3; b = 20; c = 100; }
    { a = 3; b = 20; c = 200; }
    { a = 3; b = 20; c = 300; }

    { a = 3; b = 30; c = 100; }
    { a = 3; b = 30; c = 200; }
    { a = 3; b = 30; c = 300; }
  ];
  true
