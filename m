From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 21 Aug 2003 04:50:22 +0000
Subject: Re: libunwind
Message-Id: <marc-linux-ia64-106144175706237@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106141788020789@msgid-missing>
In-Reply-To: <marc-linux-ia64-106141788020789@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 20 Aug 2003 17:05:10 -0700, Umut Aymakoglu <umuta@us.ibm.com> said:

  Umut> I need to put stack tracing into my program. To use the
  Umut> libunwinding , i need to link with the library which will
  Umut> cause problems for the customers who do not have the libunwind
  Umut> library.

Why not link it in statically?  The current libunwind is distributed
under the MIT license, so even if your application is proprietary,
there is no problem with linking it in statically.

	--david
