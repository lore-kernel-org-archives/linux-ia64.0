From: Christian Cotte-Barrot <Christian.Cotte-Barrot@bull.net>
Date: Wed, 19 Feb 2003 11:55:54 +0000
Subject: Re: [Linux-ia64] Some Modules fail w/ unresolved cpu_info__per_cpu
Message-Id: <marc-linux-ia64-105590709805871@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805176@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805176@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"Lee, Jung-Ik" wrote:
> 
> On 2.5.39,
> it fails to insmod some modules that refers to "cpu_info__per_cpu".
> That global IS DEFINE_PER_CPU'd, DECLARE_PER_CPU'd and is in System.map but
> for some reason it fails to resolve.
> Have you guys seen this ?
> 
> thanks
> J.I.
> 

That's an old story but we met the "unresolved symbol cpu_info__per_cpu"
problem again with e100.o and e1000.o modules on a 2.4.45 release.
Looks like the EXPORT_SYMBOL macro has problem to generate the
checksum for symbols defined with *PER_CPU* macros.
The kernel exports the wrong cpu_info__per_cpu_R__ver_cpu_info__per_cpu
symbol where "__ver_cpu_info__per_cpu" should be a checksum ?
Found a cleaner patch than in the past, just replaced
    EXPORT_SYMBOL(cpu_info__per_cpu);
  with
    EXPORT_SYMBOL_NOVERS(cpu_info__per_cpu);
  in
    ./arch/ia64/kernel/ia64_ksyms.c

CCB.

