From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 01 Nov 2006 19:35:28 +0000
Subject: Re: cross-compiling ia64 kernels?
Message-Id: <Pine.LNX.4.64.0611011117160.14406@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
In-Reply-To: <617E1C2C70743745A92448908E030B2AB91DF8@scsmsx411.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 1 Nov 2006, Andreas Schwab wrote:

> Read the build log.

Ok. It builds now.  One has to edit gcc-3.4.2-glibc-2.3.3.dat to have

BINUTILS_DIR=binutils-2.15
GCC_DIR=gcc-3.4.2
GLIBC_DIR=glibc-2.3.3
LINUX_DIR=linux-2.6.18
^^^^^^^^^^^^^^^^^^^^^^^
GLIBCTHREADS_FILENAME=glibc-linuxthreads-2.3.3

This looks like its pretty old software. Wonder if that will be worth it.
