From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 06 Aug 2003 15:59:34 +0000
Subject: Re: 2.4 PATCH: gcc 3.3 support
Message-Id: <marc-linux-ia64-106018677902711@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106018469231198@msgid-missing>
In-Reply-To: <marc-linux-ia64-106018469231198@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 06 August 2003 9:44 am, H. J. Lu wrote:
> This is the patch backed ported from 2.6 kernel. However, I got
> 
> # modprobe xor
> raid5: measuring checksumming speed
>    ia64      :    81.920 MB/sec
> 
> The old one I got
> 
> # modprobe xor
> raid5: measuring checksumming speed
>    8regs     :  1769.472 MB/sec
>    8regs_prefetch:  1753.088 MB/sec
>    32regs    :  2064.384 MB/sec
>    32regs_prefetch:  2064.384 MB/sec
>    ia64      :  2441.216 MB/sec
> raid5: using function: ia64 (2441.216 MB/sec)
> 
> It is very strange.

That *is* very strange.  I'll wait to apply the patch until we understand
what's happening.  Have you tried the 2.6 kernel to see what speeds it
measures?

Bjorn

