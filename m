From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 27 May 2003 18:17:47 +0000
Subject: Re: [Linux-ia64] run time code generation for IA-64
Message-Id: <marc-linux-ia64-105590723706045@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706033@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706033@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 26 May 2003 16:07:30 +0530 (IST), CH Gowri Kumar <gkumar@csa.iisc.ernet.in> said:

  CH> Also, I am storing the GP,RP etc. in R4,R5 (as they are
  CH> preserved across function calls).

Where do you have R4 and R5 before using them?  Using local (stacked)
registers instead might be a better choice here.

	--david

