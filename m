From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 18 Apr 2002 00:19:38 +0000
Subject: [Linux-ia64] Can't build ia32 support as a module
Message-Id: <marc-linux-ia64-105590701905481@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	I'm trying to reduce the size of the 2.5.8 kernel so it'll fit
on my (rather small) efi partition along with a backup kernel.
Support for IA32 binaries is given as a tristate in the config file,
but attempting to compile it as a module does not and cannot work
(IA32 support relies on extra state in the thread_struct that's
conditional on CONFIG_IA32_SUPPORT)

In the short term I suggest changing tristate to bool in the config.in
file; in the long term, rearranging the code to allow modular
installation might be nice.

Peter C

