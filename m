From: Grant Grundler <iod00d@hp.com>
Date: Tue, 22 Jun 2004 22:28:55 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <20040622222855.GG25952@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Jun 22, 2004 at 03:23:12PM -0600, Bjorn Helgaas wrote:
> Yeah, I saw it with slightly different "console=" parameters than
> David did.  So I think it's just a heisenbug and he happened to
> trip over it with a UP kernel.

ok

> Have you used salinfo_decode?  I think there's a debian package
> for it now ("salinfo").

no...too cool.

gsyprf3:~# apt-get install salinfo
Reading Package Lists... Done
Building Dependency Tree... Done
The following NEW packages will be installed:
  salinfo
0 upgraded, 1 newly installed, 0 to remove and 7 not upgraded.
Need to get 29.5kB of archives.
After unpacking 197kB of additional disk space will be used.
Get:1 http://mirrors.kernel.org testing/main salinfo 0.5-1 [29.5kB]
Fetched 29.5kB in 2s (14.3kB/s)
Selecting previously deselected package salinfo.
(Reading database ... 63823 files and directories currently installed.)
Unpacking salinfo (from .../salinfo_0.5-1_ia64.deb) ...
Setting up salinfo (0.5-1) ...
Starting salinfo decode daemons: salinfo.

gsyprf3:~# man salinfo 
No manual entry for salinfo
gsyprf3:~# 

ah it's "man salinfo_decode".

gsyprf3:/var/log/salinfo/decoded# ls
2004-06-22-06:44:21-cpu0-init.0  2004-06-22-06:44:21-cpu1-init.0  old

bits of cpu0-init.0 data:
...
  Processor static data:
    xip  : 0xa00000010005b330  xfs  : 0x8000000000000000
    xpsr : 0x00001010084a6010
...
    iip  : 0xa000000100005400  iipa : 0xa00000010005b320
    ipsr : 0x0000001008000010
...
        b0 : 0xa000000100013cb0 0x000000003f7e4620 0x0000000000000000 0x0000000000000000
        b4 : 0x0000000000000000 0x0000000000000000 0xe00000003fa43280 0xa00000010005b2a0

Reading the corresponding System.map-2.6.7:
...
a000000100005400 t general_exception
...
a00000010005b2a0 t count_reserved_pages
a00000010005b380 T mem_init
a00000010005b8c0 T ia64_set_rbs_bot
a00000010005b920 t mapped_kernel_page_is_present
a00000010005ba40 T ia64_do_page_fault


I'm wasn't 100% certain I'm looking at the right System.map file.
But both see to be identical for the above symbols.

I've made both System.map files (with and w/o EARLY_PRINTK)
and salinfo records available on
	ftp://gsyprf3.external.hp.com/pub/2.6.7/

hth,
grant
