{ python3Packages, lib }:

python3Packages.buildPythonApplication rec {
  pname = "run-sotest";
  version = "1.1.0";

  src = ./src;

  propagatedBuildInputs = with python3Packages; [ requests ];
  checkInputs = [ python3Packages.black ];

  preCheck = ''
    for pythonFile in $(find run_sotest -name "*.py"); do
      echo "black checking file $pythonFile"
      black --check --diff $pythonFile
    done
  '';

  meta = with lib; {
    description = "A utility to schedule sotest test jobs";
    longDescription = ''
      run-sotest submits test jobs to a sotest instance and waits until they are done.
    '';

    homepage = "https://sotest.io/";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
