From: Jean-Marc Saffroy <jean-marc.saffroy@ext.bull.net>
Date: Fri, 23 Apr 2004 12:43:33 +0000
Subject: Re: [PATCH] module relocation code
Message-Id: <Pine.LNX.4.44.0404231304520.1782-100000@daphne.frec.bull.fr>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
In-Reply-To: <Pine.LNX.4.44.0404211718200.1782-100000@daphne.frec.bull.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello David,

On Wed, 21 Apr 2004, David Mosberger wrote:

> Yes, the code is probably fine, but I think it could be structured
> better for better.

Do you mean there should be more generic code to handle the same problem
for other relocation types? BTW, do you have any hints as to which types
need to be fixed besides PCREL21B?

Also, you mentioned formatting problems in the patch, but I can't see any.

> BTW: a PLT is also a bit of overkill.  What you're doing is similar to
> what the GNU linker calls "relaxation" (extending the reach of a
> branch), since the gp value is the same for the caller and the callee.

Indeed, but the only benefit I can see is that we could use a smaller plt
entry that does not update gp and simply branches to the target. Only
module .init code is impacted, so I'm not sure it is worth handling it
differently.

Now, I am fairly new to relocations and the like, so maybe I am missing
something.


Best regards,

-- 
Jean-Marc Saffroy - jean-marc.saffroy@ext.bull.net

