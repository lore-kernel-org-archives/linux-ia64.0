From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 14 Oct 2004 11:10:58 +0000
Subject: Re: [RFC] Convert pgtable cache to slab
Message-Id: <16750.24258.146955.227856@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq1zn2qtpyo.fsf@wilson.mkp.net>
In-Reply-To: <yq1zn2qtpyo.fsf@wilson.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Thu, 14 Oct 2004 06:07:43 -0500, Robin Holt <holt@sgi.com> said:

  Robin> Essentially, we were allocating and clearing pages for both
  Robin> pmd and pte entries every time.

Yes, you discovered that several months ago, didn't you?  Glad the fix
came through, in the end.

	--david
