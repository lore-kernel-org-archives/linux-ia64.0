From: Tim Riker <TimR@CalderaSystems.com>
Date: Sun, 20 Feb 2000 19:32:11 +0000
Subject: [Linux-ia64] building the toolchain
Message-Id: <marc-linux-ia64-105590678204943@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ftp://ftp.cygnus.com/private/intel/

Contains the sources for the ia64 toolchain (gcc, gas, etc) Note that
www.cygnus.com has been swallowed up by redhat.com. Will the ftp site
disappear in the near future?

I've been trying to build and use these tools. I believe I am missing
some step along the way. I'm starting with the cross compiler and
attempting to build a new kernel. Here's what I've done:

rm -rf patches src local build
tar xzf patches.tgz
tar xzf src.tgz
patch -d src/gas/config/ < patches/patch.001
patch -d src/gcc/config/ia64/ < patches/patch.002
patch -d src/gcc/config/ia64/ < patches/patch.003
patch -d src/gcc/config/ia64/ < patches/patch.004
patch -d src/libgloss/ia64/ < patches/patch.005
patch -d src/gcc/config/ia64/ < patches/patch.006
patch -d src/ < patches/patch.007
patch -d src/gcc/config/ia64/ < patches/patch.008
patch -d src/opcodes/ < patches/patch.009
mkdir install
prefix=`pwd`/install
mkdir build
cd build
../src/configure --prefix=$prefix --target=ia64-cygnus-linux
make

PS: I'll be hanging on #ia64@irc.openprojects.net if anyone wants to
chat there.
-- 
Tim Riker - http://rikers.org/ - short SIGs! <g>
All I need to know I could have learned in Kindergarten
... if I'd just been paying attention.


