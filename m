From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 07 Apr 2003 22:58:13 +0000
Subject: Re: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705431@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 07 Apr 2003 18:09:44 -0400, Jes Sorensen <jes@wildopensource.com> said:

  Jes> Quoting section 4.4.7 "Memory Access Ordering", 2nd paragraph,
  Jes> it says " .... Release data accesses guarantee that all
  Jes> previous data accesses are made visible prior to being made
  Jes> visible themselves."

Oops, sorry, I got it exactly backwards. ;-(
So much for giving a "quick" reply...

  Jes> The way I understand that, it is possible that a store
  Jes> performed after an st.rel may become visible prior to the
  Jes> st.rel, like in this example:

  Jes>   st [r2] = r32		(1)
  Jes>   st.rel [r3] = r33	(2)
  Jes>   st [r4] = r34		(3)

  Jes> In other words we are only guarantied that [r2] is valid when
  Jes> [r3] appears but have no guarantie that [r4] doesn't show up on
  Jes> the bus prior to [r3]?

I wouldn't use the word "valid" here, but yes, (2) and (3) are NOT
ordered.

	--david

