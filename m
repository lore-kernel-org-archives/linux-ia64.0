From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 14 Jun 2001 04:34:40 +0000
Subject: Re: [Linux-ia64] Stack unwind functions
Message-Id: <marc-linux-ia64-105590693005730@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005729@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005729@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 13 Jun 2001 16:28:37 -0700 (PDT), rmenon@informix.com (Ram Menon) said:

  Ram> Hi, Is there any stack unwind functions available on Linux IA64
  Ram> ?.

Not at the moment.  The libgcc in gcc3.0 will have all the necessary
unwind code, but no interface to unwind the stack (it can be used for
exception handling purposes only). ;-(

	--david

