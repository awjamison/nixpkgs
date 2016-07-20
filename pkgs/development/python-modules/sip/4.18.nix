{ stdenv, fetchurl, python, isPyPy }:

if isPyPy then throw "sip not supported for interpreter ${python.executable}" else stdenv.mkDerivation rec {
  name = "sip-4.18";

  src = fetchurl {
    url = "mirror://sourceforge/pyqt/sip/${name}/${name}.tar.gz";
    sha256 = "1dlw4kyiwd9bzmd1djm79c121r219abaz86lvizdk6ksq20mrp7i";
  };

  configurePhase = ''
    ${python.executable} ./configure.py \
      -d $out/lib/${python.libPrefix}/site-packages \
      -b $out/bin -e $out/include
  '';

  buildInputs = [ python ];

  passthru.pythonPath = [];

  meta = with stdenv.lib; {
    description = "Creates C++ bindings for Python modules";
    homepage    = "http://www.riverbankcomputing.co.uk/";
    license     = licenses.gpl2Plus;
    maintainers = with maintainers; [ lovek323 sander urkud ];
    platforms   = platforms.all;
  };
}
