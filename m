From: Stephane Eranian <eranian@hpl.hp.com>
Date: Wed, 22 Dec 2004 18:10:43 +0000
Subject: gnu-efi-3.0b beta available
Message-Id: <20041222181043.GE28622@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

It's been a very long time since the last release
of the gnu-efi package.

I have just released a beta version for 3.0b. It mostly
contains updates to the loader scripts to keep up
with the latest revision of the GNU compiler.

I have tested this version on IA-64 with:
	- gcc-3.3.4 (Debian)
	- gcc-3.4 (experimental)
	- gcc-3.5 (experimental)

For IA-32, it builds with:
	- gcc-3.3.4 (Debian)
	- gcc-3.2.2 (RH9)

But unfortunately I could not test IA-32 binaries because
I do not have the right setup anymore. Any volunteer
would be greatly appreciated on this.

Please test the package in your setup with elilo or
others and report problems ASAP.

You can grab the package at:
	ftp://ftp.hpl.hp.cmo/pub/linux-ia64/gnu-efi-3.0b-041222.tar.gz
	MD5SUM: f9190bbfa8380799ba47ea03f5f12994

Thanks.

-- 
-Stephane
