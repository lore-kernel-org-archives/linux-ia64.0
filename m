From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 17 Apr 2003 20:25:38 +0000
Subject: Re: [Linux-ia64] floating-point error
Message-Id: <marc-linux-ia64-105590723705543@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705538@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705538@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 17 Apr 2003 21:21:48 +0200, Bruno Cornec <Bruno.Cornec@hp.com> said:

  Bruno> Hello,
  Bruno> We're using Oracle 9iRAC on Linux I2 for a proof of concept and are having
  Bruno> one issue.

  Bruno> Sometimes the Oracle process dies with the following error message:

  Bruno> Apr 17 20:24:48 rx1 kernel: oracle(7148): floating-point assist fault at ip 40000000048b4562

  Bruno> The ip address is always the same. This happens on all of our
  Bruno> 4 nodes as it seems randomly. I do not have other debug info
  Bruno> as this is the only message printed. Some times for the same
  Bruno> process the message is printed up to 4 times.

  Bruno> [snip...]

  Bruno> Any idea on what can cause it, and how we could debug more
  Bruno> the context ?

The message is informational.  There is probably nothing wrong with
the application, at least if the message occurs only rarely (at an
interval less than 4 messages every 10 seconds or so).  If the message
occurs all the time, then there could be a performance problem with
the application.

You should be able to turn of the message with "prctl --fpemul=silent".

	--david

