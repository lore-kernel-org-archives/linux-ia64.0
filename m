From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 08 Apr 2003 00:15:51 +0000
Subject: RE: [Linux-ia64] spin_unlock() problem
Message-Id: <marc-linux-ia64-105590723705436@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705414@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705414@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 7 Apr 2003 16:38:03 -0700, "Chen, Kenneth W" <kenneth.w.chen@intel.com> said:

  Ken> To make it to work correctly, I think one needs something like the
  Ken> following:
  Ken> --- a   Mon Apr  7 16:34:51 2003
  Ken> +++ b   Mon Apr  7 16:35:11 2003
  Ken> @@ -3,11 +3,11 @@
  Ken> spin_lock(&bleh);
  Ken> *a = foo;
  Ken> spin_unlock(&bleh);
  Ken> -   *b = bar;
  Ken> +   REL_SEMANTICS(*b) = bar;
  Ken> }

  Ken> cpu2()
  Ken> {
  Ken> -   if (*b = bar)
  Ken> +   if (ACQ_SEMANTICS(*b) = bar)
  Ken> boink(*a);
  Ken> }

Which is exactly what "volatile" would do.  Unfortunately, this
"trick" works only on ia64, so it does not solve the problem for all
Linux platforms.

	--david

