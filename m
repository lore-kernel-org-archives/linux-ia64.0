From: David Mosberger <davidm@hpl.hp.com>
Date: Wed, 18 Oct 2000 19:49:00 +0000
Subject: Re: [Linux-ia64] Problems building "2.4.0-test9" kernel source on/for IA-64
Message-Id: <marc-linux-ia64-105590678205594@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205589@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205589@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Tue, 17 Oct 2000 23:35:46 -0700, "Faccini, Bruno" <bruno.faccini@intel.com> said:

  Bruno> Trying to build "-test9" full tar-ball on/for an IA-64 SDV, I
  Bruno> got the following problems/errors

Sounds like you didn't apply the IA-64 patch in the .../ports/ia64/
directory.  Could this be the problem?

	--david

