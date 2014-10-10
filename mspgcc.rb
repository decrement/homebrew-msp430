require 'formula'

class Mspgcc < Formula
  homepage 'http://mspgcc.sourceforge.net'
  url 'https://downloads.sourceforge.net/project/mspgcc/mspgcc/mspgcc-20120406.tar.bz2'
  sha1 'cc96a7233f0b1d2c106eff7db6fc00e4ed9039a8'

  resource "Msp430Binutils" do
    url 'http://ftpmirror.gnu.org/binutils/binutils-2.21.1a.tar.bz2'
    sha1 '525255ca6874b872540c9967a1d26acfbc7c8230'
  end

  resource "Msp430BinutilsPatch" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/binutils-2.21.1a/msp430-binutils-2.21.1a-20120406.patch'
    sha1 'bb8f3a0361e52b9df9e877541d875d0eb1113e66'
  end

  resource "Msp430Gcc" do
    url 'http://ftpmirror.gnu.org/gcc/gcc-4.6.3/gcc-core-4.6.3.tar.bz2'
    sha1 'eaefb90df5a833c94560a8dda177bd1e165c2a88'
  end

  resource "Msp430GccPatch1" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/gcc-4.6.3/msp430-gcc-4.6.3-20120406.patch'
    sha1 '698ac224e7c1a5661652948a347531b27d580eca'
  end

  resource "Msp430GccPatch2" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3540953.patch'
    sha1 '9de4e74d8ceb2005409e03bf671e619f2e060082'
  end

  resource "Msp430GccPatch3" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-gcc-4.6.3-20120406-sf3559978.patch'
    sha1 '3721d13fd9a19df60fe356e082e6cea4ea637dbc'
  end

  resource "Msp430Gdb" do
    url 'http://ftpmirror.gnu.org/gdb/gdb-7.2a.tar.bz2'
    sha1 '14daf8ccf1307f148f80c8db17f8e43f545c2691'
  end

  resource "Msp430GdbPatch" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/gdb-7.2a/msp430-gdb-7.2a-20111205.patch'
    sha1 'd84c029a914a9e43533fb8afefb4db6061e007f4'
  end

  resource "Msp430mcu" do
    url 'https://downloads.sourceforge.net/project/mspgcc/msp430mcu/msp430mcu-20120406.tar.bz2'
    sha1 'c096eec84f0f287c45db713a550ec50c518fa065'
  end

  resource "Msp430mcuPatch" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430mcu-20120406-sf3522088.patch'
    sha1 '83d408fd08a1fd0b1d8ab2a300d6124423952ac4'
  end

  resource "Msp430Libc" do
    url 'https://downloads.sourceforge.net/project/mspgcc/msp430-libc/msp430-libc-20120224.tar.bz2'
    sha1 'd01cf0db41bff1a0ab50644cbb11bc5a1d5be172'
  end

  resource "Msp430LibcPatch" do
    url 'https://downloads.sourceforge.net/project/mspgcc/Patches/LTS/20120406/msp430-libc-20120224-sf3522752.patch'
    sha1 '2ca4aea9b8dcd6a199303373a8a97c7a2dd4eef6'
  end

  def install
    # add new binaries to path
    ENV.prepend 'PATH', bin, ':'

    # common configure arguments
    args = ["--prefix=#{prefix}",
            "--disable-nls",
            "--target=msp430"]

    ohai 'Building msp430-binutils'
    resource("Msp430Binutils").stage do
      (Pathname.pwd).install resource("Msp430BinutilsPatch")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-binutils-2.21.1a-20120406.patch"

      # build outside of source directory
      binutils = Dir.pwd
      mkdir '../build' do
        system "#{binutils}/configure", *args
        system 'make'
        system 'make', 'install'
      end
    end

    ohai 'Building msp430-gcc'
    resource("Msp430Gcc").stage do
      (Pathname.pwd).install resource("Msp430GccPatch1")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-gcc-4.6.3-20120406.patch"
      (Pathname.pwd).install resource("Msp430GccPatch2")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-gcc-4.6.3-20120406-sf3540953.patch"
      (Pathname.pwd).install resource("Msp430GccPatch3")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-gcc-4.6.3-20120406-sf3559978.patch"

      # wget is not shipped with OS X
      inreplace './contrib/download_prerequisites', 'wget', 'curl -OL'

      # build prerequisites along with gcc (gmp, mpc, mpfr)
      parent = "#{File.expand_path('..',Pathname.pwd)}"
      ln_s parent, parent.gsub("--", "-")
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
    resource("Msp430Gdb").stage do
      (Pathname.pwd).install resource("Msp430GdbPatch")
      # fixes "non-void function 'get_stop_addr' should return a value" errors
      inreplace 'msp430-gdb-7.2a-20111205.patch', /if \(storage_needed < 0\)\n\+    return;/m, "if (storage_needed < 0)\n+    return 0;"
      inreplace 'msp430-gdb-7.2a-20111205.patch', /if \(storage_needed == 0\)\n\+    {\n\+      return;/m, "if (storage_needed == 0)\n+    {\n+      return 0;"
      inreplace 'msp430-gdb-7.2a-20111205.patch', /if \(number_of_symbols < 0\)\n\+    return;/m, "if (number_of_symbols < 0)\n+    return 0;"
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-gdb-7.2a-20111205.patch"

      # build outside of source directory
      gdb = Dir.pwd
      mkdir '../build' do
        system "#{gdb}/configure", *args
        system 'make'
        system 'make', 'install'
      end
    end

    ohai 'Building msp430mcu'
    resource("Msp430mcu").stage do
      (Pathname.pwd).install resource("Msp430mcuPatch")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430mcu-20120406-sf3522088.patch"

      ENV['MSP430MCU_ROOT'] = Dir.pwd
      system './scripts/install.sh', prefix
    end

    ohai 'Building msp430-libc'
    resource("Msp430Libc").stage do
      (Pathname.pwd).install resource("Msp430LibcPatch")
      safe_system "/usr/bin/patch", "-g", "0", "-f", "-d", Pathname.pwd, "-p1", "-i", "msp430-libc-20120224-sf3522752.patch"

      system './configure', "--prefix=#{prefix}"
      cd 'src' do
        system 'make'
        system 'make', 'install'
      end
    end
  end
end
