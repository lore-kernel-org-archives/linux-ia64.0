From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 17 Sep 2003 22:44:20 +0000
Subject: Re: MINSIGSTKSZ on ia32
Message-Id: <marc-linux-ia64-106383895924554@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106306553008889@msgid-missing>
In-Reply-To: <marc-linux-ia64-106306553008889@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Monday 08 September 2003 5:56 pm, Arun Sharma wrote:
> 
> MINSIGSTKSZ is defined differently for i386 and ia64. This patch improves compatibility with apps which use sigaltstack(2) with sizes between MINSIGSTKSZ_IA32 and MINSIGSTKSZ.
> 
> Patches for both 2.4 and 2.6 are attached.

I applied this for 2.4, thanks.

