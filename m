From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Wed, 24 Oct 2001 19:50:24 +0000
Subject: Re: [Linux-ia64] C union on ia-64
Message-Id: <marc-linux-ia64-105590698805387@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805377@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805377@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> PS: Interestingly enought, I believe Intel's slide is actually
> wrong.  If `ULONG' is an `unsigned long' and `PVOID' is a `void *'
> then all of the data items have the same size and the two structures
> can be used interchangably on either IA32 or IA64.  It's a
> dangerous technique but it would work in this case.

I believe win64 uses P64 for its programming model.
(while we use LP64 instead)
So their ULONG is still 32bit in IA64.

Regards,
-- 
KOCHI Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


