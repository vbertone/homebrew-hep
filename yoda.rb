class Yoda < Formula
  homepage 'http://yoda.hepforge.org/'
  url 'http://www.hepforge.org/archive/yoda/YODA-1.5.8.tar.gz'
  sha256 'a6a7b3afbfaf95415148b6de9ea3b0323660b1cc3bb4e15168e9fc75b51ae0cc'

  head do
    url 'http://yoda.hepforge.org/hg/yoda', :using => :hg

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
    depends_on 'cython' => :python
  end

  depends_on :python
  depends_on 'boost'
  depends_on 'homebrew/science/root' => :optional
  option 'with-check', 'Test during installation'

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    if build.with? 'root'
      args << "--enable-root"
      ENV.append "PYTHONPATH", Formula['root'].opt_prefix/"lib/root" if build.with? 'check'
    end

    unless build.head?
      # prevent cython regeneration in YODA-1.3.1.tar.gz
      touch 'pyext/yoda/.made_pyx_templates'
      touch Dir.glob("pyext/yoda/*.{cpp,h}")
    end

    system "autoreconf", "-i" if build.head?
    system "./configure", *args
    system "make"
    system "make", "check" if build.with? 'check'
    system "make", "install"

    bash_completion.install share/'YODA/yoda-completion'
  end

  test do
    system "yoda-config", "--version"
  end
end
