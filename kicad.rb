require 'formula'

class KicadLibrary < Formula
  homepage 'https://code.launchpad.net/~kicad-lib-committers/kicad/library'
  head 'https://code.launchpad.net/~kicad-lib-committers/kicad/library', :using => :bzr

  def  patches
    [
      "https://gist.github.com/shaneburrell/5415623/raw/0d79ff29cdcc2b01a2366ec3a52ce1f2e8ef0e0f/gistfile1.txt"
    ]
  end

  def initialize
    super 'kicad-library'
  end
end

class Kicad < Formula
  homepage 'https://launchpad.net/kicad'
  head "http://bazaar.launchpad.net/~kicad-testing-committers/kicad/testing/", :using => :bzr

  depends_on 'bazaar'
  depends_on 'cmake' => :build
  depends_on :x11
  depends_on 'Wxmac'
  depends_on 'glew'
  depends_on 'cairo'
  depends_on 'doxygen'

  def patches
    [
      # enable retina display for OSX
      "https://gist.github.com/raw/4602849/2fe826c13992c4238a0462c03138f4c6aabd4968/gistfile1.txt",
      # Don't use bzr patch, it's from bzrtools which isn't part of homebrew's bazaar
      "https://gist.github.com/osterwood/7313647/raw/981455d7d6c4822cb86c23581fc67e9c9f8b9918/gistfile1.txt"
    ]
  end

  def install

    # install the component libraries
    KicadLibrary.new.brew do
      args = std_cmake_args + %W[
        -DKICAD_MODULES=#{share}/kicad/modules
        -DKICAD_LIBRARY=#{share}/kicad/library
        -DKICAD_TEMPLATES=#{share}/kicad/template
      ]
      system "cmake", ".", *args
      system "make install"
    end

    args = std_cmake_args + %W[
        -DKICAD_TESTING_VERSION=ON
        -DCMAKE_CXX_FLAGS=-D__ASSERTMACROS__
      ]

    system "cd ./pagelayout_editor/ && wget https://gist.github.com/osterwood/7330400/raw/99bd82ca0c25e47ceebc88dc5f2e03495d8c26da/Info.plist"
    system "cmake", ".", *args

    # fix the osx search path for the library components to the homebrew directory
    inreplace 'common/edaappl.cpp','/Library/Application Support/kicad', "#{HOMEBREW_PREFIX}/share/kicad"

    system "make install"
  end

  def caveats; <<-EOS.undent
    kicad.app and friends installed to:
      #{bin}

    To link the application to a normal Mac OS X location:
        brew linkapps
    or:
        ln -s #{bin}/bitmap2component.app /Applications
        ln -s #{bin}/cvpcb.app /Applications
        ln -s #{bin}/eeschema.app /Applications
        ln -s #{bin}/gerbview.app /Applications
        ln -s #{bin}/kicad.app /Applications
        ln -s #{bin}/pcb_calculation.app /Applications
        ln -s #{bin}/pcbnew.app /Applications
    EOS
  end

  def test
    # run main kicad UI
    system "open #{bin}/kicad.app"
  end
end

