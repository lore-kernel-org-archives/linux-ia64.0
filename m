From: Keith Owens <kaos@sgi.com>
Date: Thu, 09 Dec 2004 04:35:30 +0000
Subject: Re: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <9366.1102566930@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
In-Reply-To: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 8 Dec 2004 22:15:57 -0600 (CST), 
Russ Anderson <rja@sgi.com> wrote:
>Looking closer at the original code, r12 is converted to PA, but isn't used 
>after that, that I can see.  Could someone explain where r12 is used?

r12 is the stack pointer, used by the C recovery code.

