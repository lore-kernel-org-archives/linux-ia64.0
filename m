From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 27 Nov 2003 00:32:00 +0000
Subject: Re: Unwind bug on out of line code called from leaf functions
Message-Id: <marc-linux-ia64-106989314023985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106989195923088@msgid-missing>
In-Reply-To: <marc-linux-ia64-106989195923088@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 27 Nov 2003 11:12:18 +1100, Keith Owens <kaos@sgi.com> said:

  Keith> I know that gcc 3.4 overcomes this problem by saving ar.pfs
  Keith> in leaf functions and using br.call.  However we need a fix
  Keith> for gcc in the current distributions,

Sounds reasonable.

  Keith> even with gcc 3.4 we may wish to use out of line code that
  Keith> does not save ar.pfs in the future.

That would need a some solid argument!

  Keith> We need a generic fix for unwinding through out of line code
  Keith> called from leaf functions and not using br.call.  The
  Keith> obvious solution is to flag all out of line code with an
  Keith> unwind abi field and have the common unwind code reset
  Keith> ar.pfs.  Can I use .unwabi 3, 'o' for out of line?

The .unwabi directive isn't appropriate for that.  If you want such a
feature, please push it through the ABI committee to get it officially
supported.  I've said that before, I think.

	--david
