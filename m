From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Mon, 19 May 2008 07:46:14 +0000
Subject: Re: [PATCH 00/15] ia64/pv_ops take 5
Message-Id: <48313046.6030602@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <12095585682308-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <12095585682308-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Isaku Yamahata wrote:
> Yes, I also really want such a tool and I've thought of it.
> I want to prevent people from accidently breaking paravirtualization
> and only a way to do so would be by enforcing.
> I think it can be easily achived by CPP macro trick.
> At worst a simple .s (or .o) parser.
>   

For what its worth, this hasn't been a problem on x86 at all.  All the 
"interesting" instructions are used via macros/inline functions, and 
there have been no instances (that I know of, at least) of naked ones 
appearing anywhere.  And all the gatekeeper maintainers are definitely 
aware of the paravirt constraints, so I don't think any would make it 
past review.

    J
