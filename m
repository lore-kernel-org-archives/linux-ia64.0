From: "Akinobu Mita" <akinobu.mita@gmail.com>
Date: Fri, 16 Feb 2007 17:30:53 +0000
Subject: Re: fault-injection framework on ia64
Message-Id: <961aa3350702160930i63e1e64vd57130c1f05eb7f9@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
In-Reply-To: <20070215041554.8e9c92aa.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> But if STACKTRACE depends on STACKTRACE_SUPPORT, which isn't defined on ia64,
> kconfig should disable FAULT_INJECTION altogether with my patch (as it did
> before it). I don't think that FAULT_INJECTION could be enabled before my
> patch, right?
>
> _BUT_ probably STACKTRACE_SUPPORT should be defined, with default n and no
> prompt, on ia64, or Kconfig gets confused (it should output a warning,
> like 'undefined symbol STACKTRACE_SUPPORT'). We on UML used to get warning
> when INPUT was used but not defined. Hmmm....

Really? I intentionaly removed the STACKTRACE_SUPPORT in x86_64 Kconfig, then
I did make menuconfig. But I didn't get such warning.
