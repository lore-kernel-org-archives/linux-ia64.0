From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 02 Feb 2006 09:46:18 +0000
Subject: Re: [PATCH 8/12] generic hweight{32,16,8}()
Message-Id: <661de9470602020134i7f487717p6ed7641ec4d491bb@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060131164949.3365.qmail@science.horizon.com>
In-Reply-To: <20060131164949.3365.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux@horizon.com" <linux@horizon.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mita@miraclelinux.com

> This is an extremely well-known technique.  You can see a similar version
> that uses a multiply for the last few steps at
> http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
> whch refers to
> "Software Optimization Guide for AMD Athlon 64 and Opteron Processors"
> http://www.amd.com/us-en/assets/content_type/white_papers_and_tech_docs/25112.PDF
>
> It's section 8.6, "Efficient Implementation of Population-Count Function
> in 32-bit Mode", pages 179-180.

Thanks for doing this. The proof looks good except for what has been
already pointed out by Grant Grundler.
