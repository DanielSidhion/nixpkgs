{ lib, stdenv, callPackage, fetchurl
, python
, jdk, cmake, libxml2, zlib, python3, ncurses5
}:

with stdenv.lib;

let
  mkJetBrainsProduct = callPackage ./common.nix { };

  # Sorted alphabetically

  buildClion = { name, version, src, license, description, wmClass, ... }:
    lib.overrideDerivation (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "CLion";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/clion/";
        inherit description license;
        longDescription = ''
          Enhancing productivity for every C and C++
          developer on Linux, macOS and Windows.
        '';
        maintainers = with maintainers; [ edwtjo mic92 ];
        platforms = platforms.linux;
      };
    }) (attrs: {
      postFixup = (attrs.postFixup or "") + optionalString (stdenv.isLinux) ''
        (
          cd $out/clion-${version}
          # bundled cmake does not find libc
          rm -rf bin/cmake/linux
          ln -s ${cmake} bin/cmake/linux

          lldbLibPath=$out/clion-${version}/bin/lldb/linux/lib
          interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
          ln -s ${ncurses5.out}/lib/libtinfo.so.5 $lldbLibPath/libtinfo.so.5

          patchelf --set-interpreter $interp \
            --set-rpath "${lib.makeLibraryPath [ libxml2 zlib stdenv.cc.cc.lib ]}:$lldbLibPath" \
            bin/lldb/linux/bin/lldb-server

          for i in LLDBFrontend lldb lldb-argdumper; do
            patchelf --set-interpreter $interp \
              --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}:$lldbLibPath" \
              "bin/lldb/linux/bin/$i"
          done

          patchelf \
            --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}:$lldbLibPath" \
            bin/lldb/linux/lib/python3.*/lib-dynload/zlib.cpython-*m-x86_64-linux-gnu.so

          patchelf \
            --set-rpath "${lib.makeLibraryPath [ libxml2 zlib stdenv.cc.cc.lib python3 ]}:$lldbLibPath" \
            bin/lldb/linux/lib/liblldb.so

          gdbLibPath=$out/clion-${version}/bin/gdb/linux/lib
          patchelf \
            --set-rpath "$gdbLibPath" \
            bin/gdb/linux/lib/python3.*/lib-dynload/zlib.cpython-*m-x86_64-linux-gnu.so
          patchelf --set-interpreter $interp \
            --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib ]}:$gdbLibPath" \
            bin/gdb/linux/bin/gdb
          patchelf --set-interpreter $interp \
            --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}:$gdbLibPath" \
            bin/gdb/linux/bin/gdbserver

          patchelf --set-interpreter $interp \
            --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib ]}" \
            bin/clang/linux/clangd
          patchelf --set-interpreter $interp \
            --set-rpath "${lib.makeLibraryPath [ stdenv.cc.cc.lib zlib ]}" \
            bin/clang/linux/clang-tidy

          wrapProgram $out/bin/clion \
            --set CL_JDK "${jdk}"
        )
      '';
    });

  buildDataGrip = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "DataGrip";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/datagrip/";
        inherit description license;
        longDescription = ''
          DataGrip is a new IDE from JetBrains built for database admins.
          It allows you to quickly migrate and refactor relational databases,
          construct efficient, statically checked SQL queries and much more.
        '';
        maintainers = with maintainers; [ loskutov ];
        platforms = platforms.linux;
      };
    });

  buildGoland = { name, version, src, license, description, wmClass, ... }:
    lib.overrideDerivation (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "Goland";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/go/";
        inherit description license;
        longDescription = ''
          Goland is the codename for a new commercial IDE by JetBrains
          aimed at providing an ergonomic environment for Go development.
          The new IDE extends the IntelliJ platform with the coding assistance
          and tool integrations specific for the Go language
        '';
        maintainers = [ maintainers.miltador ];
        platforms = platforms.linux;
      };
    }) (attrs: {
      postFixup = (attrs.postFixup or "") + ''
        interp="$(cat $NIX_CC/nix-support/dynamic-linker)"
        patchelf --set-interpreter $interp $out/goland*/plugins/go/lib/dlv/linux/dlv

        chmod +x $out/goland*/plugins/go/lib/dlv/linux/dlv
      '';
    });

  buildIdea = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "IDEA";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/idea/";
        inherit description license;
        longDescription = ''
          IDE for Java SE, Groovy & Scala development Powerful
          environment for building Google Android apps Integration
          with JUnit, TestNG, popular SCMs, Ant & Maven. Also known
          as IntelliJ.
        '';
        maintainers = with maintainers; [ edwtjo ];
        platforms = platforms.linux ++ platforms.darwin;
      };
    });

  buildMps = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct rec {
      inherit name version src wmClass jdk;
      product = "MPS";
      meta = with stdenv.lib; {
        homepage = https://www.jetbrains.com/mps/;
        inherit license description;
        longDescription = ''
          A metaprogramming system which uses projectional editing
          which allows users to overcome the limits of language
          parsers, and build DSL editors, such as ones with tables and
          diagrams.
        '';
        maintainers = with maintainers; [ rasendubi ];
        platforms = platforms.linux;
      };
    });

  buildPhpStorm = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "PhpStorm";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/phpstorm/";
        inherit description license;
        longDescription = ''
          PhpStorm provides an editor for PHP, HTML and JavaScript
          with on-the-fly code analysis, error prevention and
          automated refactorings for PHP and JavaScript code.
        '';
        maintainers = with maintainers; [ schristo ma27 ];
        platforms = platforms.linux;
      };
    });

  buildPycharm = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "PyCharm";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/pycharm/";
        inherit description license;
        longDescription = ''
          Python IDE with complete set of tools for productive
          development with Python programming language. In addition, the
          IDE provides high-class capabilities for professional Web
          development with Django framework and Google App Engine. It
          has powerful coding assistance, navigation, a lot of
          refactoring features, tight integration with various Version
          Control Systems, Unit testing, powerful all-singing
          all-dancing Debugger and entire customization. PyCharm is
          developer driven IDE. It was developed with the aim of
          providing you almost everything you need for your comfortable
          and productive development!
        '';
        maintainers = with maintainers; [ ];
        platforms = platforms.linux;
      };
    }).override {
      propagatedUserEnvPkgs = [ python ];
    };

  buildRider = { name, version, src, license, description, wmClass, ... }:
    lib.overrideDerivation (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "Rider";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/rider/";
        inherit description license;
        longDescription = ''
          JetBrains Rider is a new .NET IDE based on the IntelliJ
          platform and ReSharper. Rider supports .NET Core,
          .NET Framework and Mono based projects. This lets you
          develop a wide array of applications including .NET desktop
          apps, services and libraries, Unity games, ASP.NET and
          ASP.NET Core web applications.
        '';
        maintainers = [ maintainers.miltador ];
        platforms = platforms.linux;
      };
    }) (attrs: {
      patchPhase = lib.optionalString (!stdenv.isDarwin) (attrs.patchPhase + ''
        # Patch built-in mono for ReSharperHost to start successfully
        interpreter=$(echo ${stdenv.glibc.out}/lib/ld-linux*.so.2)
        patchelf --set-interpreter "$interpreter" lib/ReSharperHost/linux-x64/mono/bin/mono-sgen
      '');
    });

  buildRubyMine = { name, version, src, license, description, wmClass, ... }:
    (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "RubyMine";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/ruby/";
        inherit description license;
        longDescription = description;
        maintainers = with maintainers; [ edwtjo ];
        platforms = platforms.linux;
      };
    });

  buildWebStorm = { name, version, src, license, description, wmClass, ... }:
    lib.overrideDerivation (mkJetBrainsProduct {
      inherit name version src wmClass jdk;
      product = "WebStorm";
      meta = with stdenv.lib; {
        homepage = "https://www.jetbrains.com/webstorm/";
        inherit description license;
        longDescription = ''
          WebStorm provides an editor for HTML, JavaScript (incl. Node.js),
          and CSS with on-the-fly code analysis, error prevention and
          automated refactorings for JavaScript code.
        '';
        maintainers = with maintainers; [ abaldeau ];
        platforms = platforms.linux;
      };
    }) (attrs: {
      patchPhase = (attrs.patchPhase or "") + optionalString (stdenv.isLinux) ''
        # Webstorm tries to use bundled jre if available.
        # Lets prevent this for the moment
        rm -r jbr
      '';
    });
in

{
  # Sorted alphabetically

  clion = buildClion rec {
    name = "clion-${version}";
    version = "2020.2"; /* updated by script */
    description  = "C/C++ IDE. New. Intelligent. Cross-platform";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/cpp/CLion-${version}.tar.gz";
      sha256 = "1j80k6r4nbr8abwkpx78sy3jzq3jsywn2k6g4mjx6h0adwxswymm"; /* updated by script */
    };
    wmClass = "jetbrains-clion";
    update-channel = "CLion RELEASE"; # channel's id as in http://www.jetbrains.com/updates/updates.xml
  };

  datagrip = buildDataGrip rec {
    name = "datagrip-${version}";
    version = "2020.2"; /* updated by script */
    description = "Your Swiss Army Knife for Databases and SQL";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/datagrip/${name}.tar.gz";
      sha256 = "0d0m6v4lr6qhi79csdpcyiyd2hnhlsan9lpnjmhkdxd84i1dl15a"; /* updated by script */
    };
    wmClass = "jetbrains-datagrip";
    update-channel = "DataGrip RELEASE";
  };

  goland = buildGoland rec {
    name = "goland-${version}";
    version = "2020.2.1"; /* updated by script */
    description = "Up and Coming Go IDE";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/go/${name}.tar.gz";
      sha256 = "15jd2yn4g3lya54ppcp8b0bvf2pp2khdvqba2g1aml16d5z8mkq6"; /* updated by script */
    };
    wmClass = "jetbrains-goland";
    update-channel = "GoLand RELEASE";
  };

  idea-community = buildIdea rec {
    name = "idea-community-${version}";
    version = "2020.2"; /* updated by script */
    description = "Integrated Development Environment (IDE) by Jetbrains, community edition";
    license = stdenv.lib.licenses.asl20;
    src = fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIC-${version}.tar.gz";
      sha256 = "0rymyyhgm42i487dhlxh78shyvq4hd56frgz7wrqf85hg2j5ha0y"; /* updated by script */
    };
    wmClass = "jetbrains-idea-ce";
    update-channel = "IntelliJ IDEA RELEASE";
  };

  idea-ultimate = buildIdea rec {
    name = "idea-ultimate-${version}";
    version = "2020.2"; /* updated by script */
    description = "Integrated Development Environment (IDE) by Jetbrains, requires paid license";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/idea/ideaIU-${version}-no-jbr.tar.gz";
      sha256 = "00mbf8asxjdnfciz6bl8b83kqknqdnars5w5w5w38rmza53pzxsi"; /* updated by script */
    };
    wmClass = "jetbrains-idea";
    update-channel = "IntelliJ IDEA RELEASE";
  };

  mps = buildMps rec {
    name = "mps-${version}";
    version = "2020.1.3"; /* updated by script */
    description = "Create your own domain-specific language";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/mps/2020.1/MPS-${version}.tar.gz";
      sha256 = "1ncvq834vn47pmh3q875hgqi4m7h3inljp89w3jwwhjn3g985ysz"; /* updated by script */
    };
    wmClass = "jetbrains-mps";
    update-channel = "MPS RELEASE";
  };

  phpstorm = buildPhpStorm rec {
    name = "phpstorm-${version}";
    version = "2020.2"; /* updated by script */
    description = "Professional IDE for Web and PHP developers";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/webide/PhpStorm-${version}.tar.gz";
      sha256 = "1zxhb2w7nivnx8habcf5vii6bwzaihs5x8smy0zf8ngv3xwr6vjc"; /* updated by script */
    };
    wmClass = "jetbrains-phpstorm";
    update-channel = "PhpStorm RELEASE";
  };

  pycharm-community = buildPycharm rec {
    name = "pycharm-community-${version}";
    version = "2020.2"; /* updated by script */
    description = "PyCharm Community Edition";
    license = stdenv.lib.licenses.asl20;
    src = fetchurl {
      url = "https://download.jetbrains.com/python/${name}.tar.gz";
      sha256 = "12pp3xp74dzgjrv2nz83dnqycb250kkgqlb3skjkdx9pabmfxck0"; /* updated by script */
    };
    wmClass = "jetbrains-pycharm-ce";
    update-channel = "PyCharm RELEASE";
  };

  pycharm-professional = buildPycharm rec {
    name = "pycharm-professional-${version}";
    version = "2020.2"; /* updated by script */
    description = "PyCharm Professional Edition";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/python/${name}.tar.gz";
      sha256 = "0xq0nba31yc7cm1lbgkmgfbr5kp5fq5k7j2n6kampm2hyx5fa0ak"; /* updated by script */
    };
    wmClass = "jetbrains-pycharm";
    update-channel = "PyCharm RELEASE";
  };

  rider = buildRider rec {
    name = "rider-${version}";
    version = "2020.1.4"; /* updated by script */
    description = "A cross-platform .NET IDE based on the IntelliJ platform and ReSharper";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      sha256 = "0vicgwgsbllfw6fz4l82x4vbka3agf541576ix9akyvsskwbaxj9"; /* updated by script */
    };
    wmClass = "jetbrains-rider";
    update-channel = "Rider RELEASE";
  };

  ruby-mine = buildRubyMine rec {
    name = "ruby-mine-${version}";
    version = "2020.2"; /* updated by script */
    description = "The Most Intelligent Ruby and Rails IDE";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/ruby/RubyMine-${version}.tar.gz";
      sha256 = "1caxd5qcxwwrdy3ma87gnywr5czg3lam1n2gwbnc7hdxgfnvn3qz"; /* updated by script */
    };
    wmClass = "jetbrains-rubymine";
    update-channel = "RubyMine RELEASE";
  };

  webstorm = buildWebStorm rec {
    name = "webstorm-${version}";
    version = "2020.2"; /* updated by script */
    description = "Professional IDE for Web and JavaScript development";
    license = stdenv.lib.licenses.unfree;
    src = fetchurl {
      url = "https://download.jetbrains.com/webstorm/WebStorm-${version}.tar.gz";
      sha256 = "100j2q9hz0a50n3x3khk7hap7b496g6sx0y6q7n7vy2zayh5ibm5"; /* updated by script */
    };
    wmClass = "jetbrains-webstorm";
    update-channel = "WebStorm RELEASE";
  };

}
