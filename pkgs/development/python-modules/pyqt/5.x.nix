{ stdenv, fetchurl, python, pkgconfig, qtbase, qtsvg, qtwebengine, sip
, pythonDBus, lndir, makeWrapper, qmakeHook }:

let
  version = "5.6";
in stdenv.mkDerivation {
  name = "${python.libPrefix}-PyQt-${version}";

  meta = with stdenv.lib; {
    description = "Python bindings for Qt5";
    homepage    = http://www.riverbankcomputing.co.uk;
    license     = licenses.gpl3;
    platforms   = platforms.mesaPlatforms;
    maintainers = with maintainers; [ sander ];
  };

  src = fetchurl {
    url = "mirror://sourceforge/pyqt/PyQt5/PyQt-${version}/PyQt5_gpl-${version}.tar.gz";
    sha256 = "1qgh42zsr9jppl9k7fcdbhxcd1wrb7wyaj9lng9nxfa19in1lj1f";
  };

  buildInputs = [
    python pkgconfig makeWrapper lndir
    qtbase qtsvg qtwebengine qmakeHook
  ];

  propagatedBuildInputs = [ sip ];

  configurePhase = ''
    runHook preConfigure

    mkdir -p $out
    lndir ${pythonDBus} $out

    export PYTHONPATH=$PYTHONPATH:$out/lib/${python.libPrefix}/site-packages

    substituteInPlace configure.py \
      --replace 'install_dir=pydbusmoddir' "install_dir='$out/lib/${python.libPrefix}/site-packages/dbus/mainloop'" \

    ${python.executable} configure.py  -w \
      --confirm-license \
      --dbus=$out/include/dbus-1.0 \
      --qmake=$QMAKE \
      --no-qml-plugin \
      --bindir=$out/bin \
      --destdir=$out/lib/${python.libPrefix}/site-packages \
      --sipdir=$out/share/sip \
      --designer-plugindir=$out/plugins/designer

    runHook postConfigure
  '';

  postInstall = ''
    for i in $out/bin/*; do
      wrapProgram $i --prefix PYTHONPATH : "$PYTHONPATH"
    done
  '';

  enableParallelBuilding = true;

  passthru.pythonPath = [];
}
