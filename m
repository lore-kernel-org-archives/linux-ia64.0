From: Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net>
Date: Wed, 21 Apr 2004 22:50:59 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <Pine.LNX.4.44.0404220034030.1782-100000@daphne.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, 21 Apr 2004, David Mosberger wrote:

> Apart from formatting issues, I didn't see where/how the patch handles
> the case in_core() && !in_init(), but that's just based on a quick read.

The code uses <val> to fix the relocation at <location>:
 - location is always in the module, so either in core or in init
 - val can be in core, in init, or far, far away (kernel or other module)

When val and location are both in init or both in core, there's nothing to
do[*]. When val and location are in different areas, I always use a plt
(and then a function descriptor for val is needed if val is in the
module).


[*] unless the text grows larger than 32MB, now that I think about it. It 
may be better to use a plt depending on the offset between val and plt, 
after all.

-- 
Jean-Marc Saffroy - jean-marc.saffroy@ext.bull.net

