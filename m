From: Grant Grundler <iod00d@hp.com>
Date: Fri, 17 Oct 2003 01:12:12 +0000
Subject: Re: type 95 for .text?
Message-Id: <marc-linux-ia64-106635314310124@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106634361902844@msgid-missing>
In-Reply-To: <marc-linux-ia64-106634361902844@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Oct 17, 2003 at 11:04:52AM +1000, Keith Owens wrote:
> for i in $(find /lib/modules/2.4.23-pre6 -type f); do readelf -h $i 2>/dev/null | (grep 'constant gp' > /dev/null && echo $i has constant gp); done

hey! don't make it too easy for me! :^)

/lib/modules/2.4.23-pre6/kernel/arch/ia64/lib/xor.o has constant gp

I just added that...sounds like bjorn should ignore my patch
since the module isn't getting built correctly. *sigh*.

grant
