From: Clemens Ladisch <clemens@ladisch.de>
Date: Mon, 02 Jun 2014 07:24:04 +0000
Subject: Re: [PATCH] arch: ia64: kernel: palinfo.c:  Optimization of the Code
Message-Id: <538C2694.1090308@ladisch.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1401659019-17586-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
In-Reply-To: <1401659019-17586-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Rickard Strandqvist wrote:
> From what I know, AND is faster then modulo.

Which is why the compiler does this optimization automatically,
if it can prove that it is correct.

> -		if (i != 0 && (i%64) = 0)
> +		if (i != 0 && (i&63) = 0)

Did you prove that i cannot be negative?


Regards,
Clemens
