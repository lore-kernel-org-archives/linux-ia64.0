From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Mon, 10 Nov 2003 21:45:23 +0000
Subject: RE: Problem with accessing page tables
Message-Id: <marc-linux-ia64-106850075314625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106826502101883@msgid-missing>
In-Reply-To: <marc-linux-ia64-106826502101883@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Sat, 8 Nov 2003 13:27:02 +0530, "Ameya Mitragotri" <ameya.mitragotri@wipro.com> said:

  Ameya> We passed the address of swapper_pg_dir and this is what we got.

  Ameya> Nov  8 12:29:35 i2 kernel: The swapper_pg_dir address is
  Ameya> a0000001008d6000
  Ameya> Nov  8 12:29:35 i2 kernel: The pgd offset is 280 address of pgd entry is
  Ameya> a0000001008d6000 value @ pgd entry is 2146033664
  Ameya> Nov  8 12:29:35 i2 kernel: The pmd offset is 201 pmd address is
  Ameya> e00000007fe9f008
  Ameya> value @ pmd is 0

  Ameya> Now I think the memory for the swapper_pg_dir has already been
  Ameya> allocated.
  Ameya> I still get PMD as 0.

Again, that's normal for memory that hasn't been allocated yet.

  Ameya> Am I doing something fundamentally wrong?

I don't know.  What exactly are you trying to do?

	--david
