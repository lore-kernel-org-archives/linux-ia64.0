From: Grant Grundler <iod00d@hp.com>
Date: Mon, 07 Mar 2005 23:31:03 +0000
Subject: Re: PCI Express
Message-Id: <20050307233103.GA2164@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4228F250.7C5E2E3C@sgi.com>
In-Reply-To: <4228F250.7C5E2E3C@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Mar 07, 2005 at 02:40:42PM -0600, Colin Ngam wrote:
> I looked at Documentation/MSI-HOWTO.txt(linux-ia64-release-2.6.11) and 
> it mentioned that CONFIG_X86_LOCAL_APIC has to be configured.  I did not 
> find this configured on in any sample ia64 config files, but it does 
> exist in defconfig for i386.  Is this just an ia32 config option?

yes

> >I'm having trouble with the word "supported".
> >You have a PCI-E Bridge and firmware that can talk to it
> >hooked up to an ia64 box?
> Pretty soon.
> Is there any ia64 box with MSI and PCIE actually "activated and running"?

I've not seen anything published yet.

*Some* x86-64 boxes have working MSI (and PCI-E).
Recent PCI quirks have been submitted to flag the AMD chipsets that don't
support MSI or MSI-X.

grant
