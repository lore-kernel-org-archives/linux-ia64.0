From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Mon, 16 May 2005 09:41:16 +0000
Subject: Re: elf header bits for page migration support......
Message-Id: <17032.27324.517764.350186@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <42847F6B.3080609@engr.sgi.com>
In-Reply-To: <42847F6B.3080609@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "H" = H J Lu <hjl@lucon.org> writes:

H> On Fri, May 13, 2005 at 05:20:27AM -0500, Ray Bryant wrote:
>> Tony,
>> 
>> The alternative being suggested is to mark the elf header of object
>> files that should only have shared pages migrated, or that should
>> not be migrated (e. g. you don't want to migrate /bin/csh all the
>> time.)
>> 
Would the program header not be a better place?  There are spare bits
there, I believe, and then each PT_LOAD segment could have a different
attribute, perhaps.
-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
