From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Mon, 07 Apr 2003 23:38:03 +0000
Subject: RE: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705434@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I'm confused with the original example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   *b = bar;
   spin_unlock(&bleh);
}

cpu2()
{
   if (*b == bar)
      boink(*a);
}

*b is protected by spin_lock bleh, then in cpu2() one need a spin_lock
to access *b.  To me, the code above has bug in it.


Then the discussion flows into following example:

cpu1()
{
   spin_lock(&bleh);
   *a = foo;
   spin_unlock(&bleh);
   *b = bar;
}

cpu2()
{
   if (*b == bar)
      boink(*a);
}

Which also doesn't gareentee the order of *b because it is outside a
spin_lock and there is no explicit memory ordering in the code.

To make it to work correctly, I think one needs something like the
following:
--- a   Mon Apr  7 16:34:51 2003
+++ b   Mon Apr  7 16:35:11 2003
@@ -3,11 +3,11 @@
    spin_lock(&bleh);
    *a = foo;
    spin_unlock(&bleh);
-   *b = bar;
+   REL_SEMANTICS(*b) = bar;
 }
 
 cpu2()
 {
-   if (*b == bar)
+   if (ACQ_SEMANTICS(*b) == bar)
       boink(*a);
 }

Again, this is a program bug to me.

- Ken

-----Original Message-----
From: Jes Sorensen [mailto:jes@wildopensource.com] 
Sent: Monday, April 07, 2003 4:14 PM
To: davidm@hpl.hp.com
Cc: 'linux-ia64@linuxia64.org '; 'wildos@sgi.com '
Subject: Re: [Linux-ia64] spin_unlock() problem

>>>>> "David" == David Mosberger <davidm@napali.hpl.hp.com> writes:

>>>>> On 07 Apr 2003 18:09:44 -0400, Jes Sorensen
<jes@wildopensource.com> said:
David> Oops, sorry, I got it exactly backwards. ;-( So much for giving
David> a "quick" reply...

Heh, for a quick answer you sure were very convincing. I have
convinced myself for and against this one several times so far ;-)

Jes> In other words we are only guarantied that [r2] is valid when
Jes> [r3] appears but have no guarantie that [r4] doesn't show up on
Jes> the bus prior to [r3]?

David> I wouldn't use the word "valid" here, but yes, (2) and (3) are
David> NOT ordered.

This is the situation I was trying to fix, adding a wmb() to
spin_unlock() seems the only way to get around it as far as I can see.
I take it you agree then?

Cheers,
Jes

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64

