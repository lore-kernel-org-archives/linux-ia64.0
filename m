From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 13 Oct 2003 19:01:38 +0000
Subject: Re: libunwind question
Message-Id: <marc-linux-ia64-106607171714962@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106606816410248@msgid-missing>
In-Reply-To: <marc-linux-ia64-106606816410248@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 13 Oct 2003 11:01:47 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> During unwinding is there a way to tell if the ip is from a
  Umut> shared library or from an executable and get the name of the
  Umut> object it is from?

Not with libunwind itself.

  Umut> I use the unw_get_proc_name() call to get the symbol name but
  Umut> would like to get the name of the object as well.

You should be able to get that by walking the list of mapped objects.
You can get that with dl_iterate_phdr().  The callback will be invoked
once for each object and then you can check the ELF PHDR to see if the
IP falls inside the object.

	--david

PS: I'm cc'ing libunwind, since that's probably a more appropriate place
    to discuss such issues.
