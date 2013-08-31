require 'formula'

class Msp430Binutils < Formula
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.21.1a.tar.bz2'
  sha1 '525255ca6874b872540c9967a1d26acfbc7c8230'

  def patches
    'http://downloads.sourceforge.net/project/mspgcc/Patches/binutils-2.21.1a/msp430-binutils-2.21.1a-20120406.patch'
  end
end

class Msp430Gcc < Formula
  url 'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-core-4.6.3.tar.bz2'
  sha1 'eaefb90df5a833c94560a8dda177bd1e165c2a88'

  def patches
    [
      'http://downloads.sourceforge.net/project/mspgcc/Patches/gcc-4.6.3/msp430-gcc-4.6.3-20120406.patch',
      'http://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3540953.patch',
      'http://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3559978.patch'
    ]
  end
end

class Msp430Gdb < Formula
  url 'http://ftpmirror.gnu.org/gdb/gdb-7.2a.tar.bz2'
  sha1 '14daf8ccf1307f148f80c8db17f8e43f545c2691'

  def patches
    [
      'http://downloads.sourceforge.net/project/mspgcc/Patches/gdb-7.2a/msp430-gdb-7.2a-20111205.patch',

      # fixes "non-void function 'get_stop_addr' should return a value" errors
      DATA
    ]
  end
end

class Msp430mcu < Formula
  url 'http://downloads.sourceforge.net/project/mspgcc/msp430mcu/msp430mcu-20120406.tar.bz2'
  sha1 'c096eec84f0f287c45db713a550ec50c518fa065'

  def patches
    'http://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430mcu-20120406-sf3522088.patch'
  end
end

class Msp430Libc < Formula
  url 'http://downloads.sourceforge.net/project/mspgcc/msp430-libc/msp430-libc-20120224.tar.bz2'
  sha1 'd01cf0db41bff1a0ab50644cbb11bc5a1d5be172'

  def patches
    'http://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-libc-20120224-sf3522752.patch'
  end
end

class Mspgcc < Formula
  homepage 'http://mspgcc.sourceforge.net'
  url 'http://downloads.sourceforge.net/project/mspgcc/mspgcc/mspgcc-20120406.tar.bz2'
  sha1 'cc96a7233f0b1d2c106eff7db6fc00e4ed9039a8'

  def install
    # add new binaries to path
    ENV.prepend 'PATH', bin, ':'

    # common configure arguments
    args = ["--prefix=#{prefix}",
            "--disable-nls",
            "--target=msp430"]

    ohai 'Building msp430-binutils'
    Msp430Binutils.new.brew do
      # build outside of source directory
      binutils = Dir.pwd
      mkdir '../build' do
        system "#{binutils}/configure", *args
        system 'make'
        system 'make', 'install'
      end
    end

    ohai 'Building msp430-gcc'
    Msp430Gcc.new.brew do
      # wget is not shipped with OS X
      inreplace './contrib/download_prerequisites', 'wget', 'curl -OL'

      # build prerequisites along with gcc (gmp, mpc, mpfr)
      system './contrib/download_prerequisites'

      # build outside of source directory
      gcc = Dir.pwd
      mkdir '../build' do
        system "#{gcc}/configure", '--enable-languages=c', *args
        system 'make'
        system 'make', 'install'
      end
    end

    ohai 'Building msp430-gdb'
    Msp430Gdb.new.brew do
      # build outside of source directory
      gdb = Dir.pwd
      mkdir '../build' do
        system "#{gdb}/configure", *args
        system 'make'
        system 'make', 'install'
      end
    end

    ohai 'Building msp430mcu'
    Msp430mcu.new.brew do
      ENV['MSP430MCU_ROOT'] = Dir.pwd
      system './scripts/install.sh', prefix
    end

    ohai 'Building msp430-libc'
    Msp430Libc.new.brew do
      system './configure', "--prefix=#{prefix}"
      cd 'src' do
        system 'make'
        system 'make', 'install'
      end
    end
  end
end

__END__
diff --git gdb-7.2a.orig/sim/msp430/interp.c gdb-7.2a/sim/msp430/interp.c
index 5778c89..077e6ea 100644
--- gdb-7.2a.orig/sim/msp430/interp.c
+++ gdb-7.2a/sim/msp430/interp.c
@@ -1880,18 +1880,18 @@ get_stop_addr (struct bfd *abfd)
   storage_needed = bfd_get_symtab_upper_bound (abfd);
 
   if (storage_needed < 0)
-    return;
+    return 0;
 
   if (storage_needed == 0)
     {
-      return;
+      return 0;
     }
 
   symbol_table = (asymbol **) xmalloc (storage_needed);
   number_of_symbols = bfd_canonicalize_symtab (abfd, symbol_table);
 
   if (number_of_symbols < 0)
-    return;
+    return 0;
 
   for (i = 0; i < number_of_symbols; i++)
     {
