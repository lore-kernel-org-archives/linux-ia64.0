From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 16 Dec 2003 17:38:08 +0000
Subject: Re: Link error with gcc-3.3
Message-Id: <marc-linux-ia64-107159648026302@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107159101718747@msgid-missing>
In-Reply-To: <marc-linux-ia64-107159101718747@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 16 Dec 2003 11:09:54 -0500, Martin Hicks <mort@wildopensource.com> said:

  Martin> The latest linux-ia64-2.5 bk fails to link with the
  Martin> following error while using gcc-3.3 from debian-sid:

  Martin> undefined reference to `ia64_spinlock_contention_pre3_4'

My bad: I forgot to update ia64_ksyms.c after enabling the proper code
for gcc 3.3.  Should be fixed now.

	--david
