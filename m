From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 17 Mar 2004 18:54:06 +0000
Subject: Re: UCE and NUMA
Message-Id: <16472.40654.679214.502105@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <40576628.927DEB35@email.mot.com>
In-Reply-To: <40576628.927DEB35@email.mot.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 17 Mar 2004 10:57:38 -0600, Mario Smarduch <cms063@email.mot.com> said:

  Mario> But I agree practically it would be pretty difficult to (i)
  Mario> first figure out what is very contentious (ii) and locate all
  Mario> your locks/data into those UCE pages. So in short UCE is not
  Mario> used in any kernel version?

Not as far as I know.  I really don't even know which platforms
support fetchadd via UCE.

	--david
