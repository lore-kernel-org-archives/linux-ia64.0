From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 23 Jan 2004 22:28:31 +0000
Subject: Re: Loadable module and kernel gp
Message-Id: <16401.40975.3047.129947@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4010EEC0.7020003@hob.de>
In-Reply-To: <4010EEC0.7020003@hob.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 23 Jan 2004 10:52:00 +0100, Christian Hildner <christian.hildner@hob.de> said:

  Christian> Hi, does anybody know a simple way for a loadable module
  Christian> to get the gp value of the kernel? Is there any sample
  Christian> code?

The safest way is probably to materialize a function pointer for a
function that is known to be in the kernel (and exported) and then to
read the second word.

	--david
