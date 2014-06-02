From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Date: Mon, 02 Jun 2014 17:59:39 +0000
Subject: Re: [PATCH] arch: ia64: kernel: palinfo.c: Optimization of the Code
Message-Id: <CAFo99gaF5ax4uVn1UCxqh5S158bYsiAtV9T6h3Z=zT0ucQzSyw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1401659019-17586-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<538C2694.1090308@ladisch.de>
In-Reply-To: <538C2694.1090308@ladisch.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Clemens Ladisch <clemens@ladisch.de>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi

Thought I would be able to do that. But after testing, I could not
measure any difference.

Thought it would make a noticeable difference, but guess gcc resolve
this in the best way.


Best regards
Rickard Strandqvist


2014-06-02 9:24 GMT+02:00 Clemens Ladisch <clemens@ladisch.de>:
> Rickard Strandqvist wrote:
>> From what I know, AND is faster then modulo.
>
> Which is why the compiler does this optimization automatically,
> if it can prove that it is correct.
>
>> -             if (i != 0 && (i%64) = 0)
>> +             if (i != 0 && (i&63) = 0)
>
> Did you prove that i cannot be negative?
>
>
> Regards,
> Clemens
