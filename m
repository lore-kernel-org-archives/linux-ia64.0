From: "Kotian, Deepak" <Deepak.Kotian@patni.com>
Date: Wed, 11 Feb 2004 11:59:17 +0000
Subject: Query regarding Itanium (Mapping of register values)
Message-Id: <374639AB1012AA4C840022842AA95BC20138E3FC@ruby.patni.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	Hi , 
	We have a program for core analysis. We have a query regarding the mapping of register values. The query is as follows: 
	************************************************************************************************************************************************* 
	We have used "gregset_t" which is an array of 128 elements (say reg[128]). Each element of the array is of unsigned long data type. The type gregset_t is defined in sys/procfs.h and is used to store the general purpose register values. 
	The register values of all the 128 elements i.e. reg[0] to reg[127] is coming correctly. We have compared the values with the ones in the debugger. These values are matching. 
	1. But, we are not sure about what value is stored in which register array element ?
	For eg: We are DIRECTLY using reg[12] for the value of stack pointer (sp) and reg[13] for the value of base pointer (bp) .Is this mapping correct ? 
	2. How can the instruction pointer (ip) be calculated using the register values stored in the register array reg[] ? 
	3. Out of reg[0] to reg[127] , which array elements contain the following application register values ?
	( ar.ccv (Compare and exchange compare value register),
	ar.bsp (Backing store pointer), 
	ar.bspstore(Backing store pointer for memory stores), 
	ar.itc (Interval time counter), 
	ar.rsc(Register stack configuration), 
	ar.rnat (RSE Nat collection register), 
	ar.unat (User NaT collection register), 
	ar.fpsr (Floating point status register), 
	ar.pfs (Previous function state), 
	ar.lc (Loop counter register), 
	ar.ec (Epilog count register),
	cfm (Current frame marker) ) 
	************************************************************************************************************************************************* 
	Please let us know your views on this. 
	Thanks and Regards, 
	Deepak

