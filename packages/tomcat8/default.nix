{ stdenv, lib, fetchurl }:

stdenv.mkDerivation rec {
  pname = "apache-tomcat";
  version = "8.5.51";

  src = fetchurl {
    url = "mirror://apache/tomcat/tomcat-8/v${version}/bin/${pname}-${version}.tar.gz";
    sha256 = "1zmg0hi4nw4y5sknd0jgq9lb3bncjjscay5fdiiq3qh5cs0wsvl3";
  };

  outputs = [ "out" "webapps" ];

  installPhase = ''
    mkdir $out
    mv * $out
    mkdir -p $webapps/webapps
    mv $out/webapps $webapps/
  '';

  meta = {
    homepage = "https://tomcat.apache.org/";
    description = "An implementation of the Java Servlet and JavaServer Pages technologies";
    platforms = lib.platforms.all;
    license = [ lib.licenses.asl20 ];
  };
}
