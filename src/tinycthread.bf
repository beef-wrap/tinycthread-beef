/* -*- mode: c; tab-width: 2; indent-tabs-mode: nil; -*-
Copyright (c) 2012 Marcus Geelnard
Copyright (c) 2013-2016 Evan Nemerson

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

	1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.

	2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.

	3. This notice may not be removed or altered from any source
	distribution.
*/

using System;
using System.Interop;

namespace tinycthread;

public static class tinycthread
{
	typealias HANDLE = void*;
	typealias pthread_t = void*;

	/**
	* @file
	* @mainpage TinyCThread API Reference
	*
	* @section intro_sec Introduction
	* TinyCThread is a minimal, portable implementation of basic threading
	* classes for C.
	*
	* They closely mimic the functionality and naming of the C11 standard, and
	* should be easily replaceable with the corresponding standard variants.
	*
	* @section port_sec Portability
	* The Win32 variant uses the native Win32 API for implementing the thread
	* classes, while for other systems, the POSIX threads API (pthread) is used.
	*
	* @section misc_sec Miscellaneous
	* The following special keywords are available: #_Thread_local.
	*
	* For more detailed information, browse the different sections of this
	* documentation. A good place to start is:
	* tinycthread.h.
	*/

	public struct timespec { }

	[CLink] public static extern int _tthread_timespec_get(timespec* ts, int base_);

	/** TinyCThread version (major number). */
	const int TINYCTHREAD_VERSION_MAJOR = 1;
	/** TinyCThread version (minor number). */
	const int TINYCTHREAD_VERSION_MINOR = 2;
	/** TinyCThread version (full version). */
	const int TINYCTHREAD_VERSION = (TINYCTHREAD_VERSION_MAJOR * 100 + TINYCTHREAD_VERSION_MINOR);

	/**
	* @def _Thread_local
	* Thread local storage keyword.
	* A variable that is declared with the @c _Thread_local keyword makes the
	* value of the variable local to each thread (known as thread-local storage,
	* or TLS). Example usage:
	* @code
	* // This variable is local to each thread.
	* _Thread_local int variable;
	* @endcode
	* @note The @c _Thread_local keyword is a macro that maps to the corresponding
	* compiler directive (e.g. @c __declspec(thread)).
	* @note This directive is currently not supported on Mac OS X (it will give
	* a compiler error), since compile-time TLS is not supported in the Mac OS X
	* executable format. Also, some older versions of MinGW (before GCC 4.x) do
	* not support this directive, nor does the Tiny C Compiler.
	* @hideinitializer
	*/

	// #if !(defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 201102L)) && !defined(_Thread_local)
	//  #if defined(__GNUC__) || defined(__INTEL_COMPILER) || defined(__SUNPRO_CC) || defined(__IBMCPP__)
	//   #define _Thread_local __thread
	//  #else
	//   #define _Thread_local __declspec(thread)
	//  #endif
	// #elif defined(__GNUC__) && defined(__GNUC_MINOR__) && (((__GNUC__ << 8) | __GNUC_MINOR__) < ((4 << 8) | 9))
	//  #define _Thread_local __thread
	// #endif

	/* Macros */
	// #if defined(_TTHREAD_WIN32_)
	// #define TSS_DTOR_ITERATIONS (4)
	// #else
	// #define TSS_DTOR_ITERATIONS PTHREAD_DESTRUCTOR_ITERATIONS
	// #endif

	/* Function return values */
	public const c_int thrd_error    = 0; /**< The requested operation failed */
	public const c_int thrd_success  = 1; /**< The requested operation succeeded */
	public const c_int thrd_timedout = 2; /**< The time specified in the call was reached without acquiring the requested resource */
	public const c_int thrd_busy     = 3; /**< The requested operation failed because a tesource requested by a test and return function is already in use */
	public const c_int thrd_nomem    = 4; /**< The requested operation failed because it was unable to allocate memory */

	/* Mutex types */
	public const c_int mtx_plain     = 0;
	public const c_int mtx_timed     = 1;
	public const c_int mtx_recursive = 2;

	/* Mutex */
	public struct mtx_t { }

	/** Create a mutex object.
	* @param mtx A mutex object.
	* @param type Bit-mask that must have one of the following six values:
	*   @li @c mtx_plain for a simple non-recursive mutex
	*   @li @c mtx_timed for a non-recursive mutex that supports timeout
	*   @li @c mtx_plain | @c mtx_recursive (same as @c mtx_plain, but recursive)
	*   @li @c mtx_timed | @c mtx_recursive (same as @c mtx_timed, but recursive)
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int mtx_init(mtx_t* mtx, int type);

	/** Release any resources used by the given mutex.
	* @param mtx A mutex object.
	*/
	[CLink] public static extern void mtx_destroy(mtx_t* mtx);

	/** Lock the given mutex.
	* Blocks until the given mutex can be locked. If the mutex is non-recursive, and
	* the calling thread already has a lock on the mutex, this call will block
	* forever.
	* @param mtx A mutex object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int mtx_lock(mtx_t* mtx);

	/** Lock the given mutex, or block until a specific point in time.
	* Blocks until either the given mutex can be locked, or the specified TIME_UTC
	* based time.
	* @param mtx A mutex object.
	* @param ts A UTC based calendar time
	* @return @ref The mtx_timedlock function returns thrd_success on success, or
	* thrd_timedout if the time specified was reached without acquiring the
	* requested resource, or thrd_error if the request could not be honored.
	*/
	[CLink] public static extern int mtx_timedlock(mtx_t* mtx, timespec* ts);

	/** Try to lock the given mutex.
	* The specified mutex shall support either test and return or timeout. If the
	* mutex is already locked, the function returns without blocking.
	* @param mtx A mutex object.
	* @return @ref thrd_success on success, or @ref thrd_busy if the resource
	* requested is already in use, or @ref thrd_error if the request could not be
	* honored.
	*/
	[CLink] public static extern int mtx_trylock(mtx_t* mtx);

	/** Unlock the given mutex.
	* @param mtx A mutex object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int mtx_unlock(mtx_t* mtx);

	/* Condition variable */
	public struct cnd_t { }

	/** Create a condition variable object.
	* @param cond A condition variable object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int cnd_init(cnd_t* cond);

	/** Release any resources used by the given condition variable.
	* @param cond A condition variable object.
	*/
	[CLink] public static extern void cnd_destroy(cnd_t* cond);

	/** Signal a condition variable.
	* Unblocks one of the threads that are blocked on the given condition variable
	* at the time of the call. If no threads are blocked on the condition variable
	* at the time of the call, the function does nothing and return success.
	* @param cond A condition variable object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int cnd_signal(cnd_t* cond);

	/** Broadcast a condition variable.
	* Unblocks all of the threads that are blocked on the given condition variable
	* at the time of the call. If no threads are blocked on the condition variable
	* at the time of the call, the function does nothing and return success.
	* @param cond A condition variable object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int cnd_broadcast(cnd_t* cond);

	/** Wait for a condition variable to become signaled.
	* The function atomically unlocks the given mutex and endeavors to block until
	* the given condition variable is signaled by a call to cnd_signal or to
	* cnd_broadcast. When the calling thread becomes unblocked it locks the mutex
	* before it returns.
	* @param cond A condition variable object.
	* @param mtx A mutex object.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int cnd_wait(cnd_t* cond, mtx_t* mtx);

	/** Wait for a condition variable to become signaled.
	* The function atomically unlocks the given mutex and endeavors to block until
	* the given condition variable is signaled by a call to cnd_signal or to
	* cnd_broadcast, or until after the specified time. When the calling thread
	* becomes unblocked it locks the mutex before it returns.
	* @param cond A condition variable object.
	* @param mtx A mutex object.
	* @param xt A point in time at which the request will time out (absolute time).
	* @return @ref thrd_success upon success, or @ref thrd_timeout if the time
	* specified in the call was reached without acquiring the requested resource, or
	* @ref thrd_error if the request could not be honored.
	*/
	[CLink] public static extern int cnd_timedwait(cnd_t* cond, mtx_t* mtx, timespec* ts);

	/* Thread */

#if BF_PLATFORM_WINDOWS
	public typealias thrd_t = HANDLE;
#else
	public typealias thrd_t = pthread_t;
#endif

	/** Thread start function.
	* Any thread that is started with the @ref thrd_create() function must be
	* started through a function of this type.
	* @param arg The thread argument (the @c arg argument of the corresponding
	*        @ref thrd_create() call).
	* @return The thread return value, which can be obtained by another thread
	* by using the @ref thrd_join() function.
	*/
	public function int thrd_start_t(void* arg);

	/** Create a new thread.
	* @param thr Identifier of the newly created thread.
	* @param func A function pointer to the function that will be executed in
	*        the new thread.
	* @param arg An argument to the thread function.
	* @return @ref thrd_success on success, or @ref thrd_nomem if no memory could
	* be allocated for the thread requested, or @ref thrd_error if the request
	* could not be honored.
	* @note A thread’s identifier may be reused for a different thread once the
	* original thread has exited and either been detached or joined to another
	* thread.
	*/
	[CLink] public static extern int thrd_create(thrd_t* thr, thrd_start_t func, void* arg);

	/** Identify the calling thread.
	* @return The identifier of the calling thread.
	*/
	[CLink] public static extern thrd_t thrd_current();

	/** Dispose of any resources allocated to the thread when that thread exits.
	* @return thrd_success, or thrd_error on error
	*/
	[CLink] public static extern int thrd_detach(thrd_t thr);

	/** Compare two thread identifiers.
	* The function determines if two thread identifiers refer to the same thread.
	* @return Zero if the two thread identifiers refer to different threads.
	* Otherwise a nonzero value is returned.
	*/
	[CLink] public static extern int thrd_equal(thrd_t thr0, thrd_t thr1);

	/** Terminate execution of the calling thread.
	* @param res Result code of the calling thread.
	*/
	[CLink] public static extern void thrd_exit(int res);

	/** Wait for a thread to terminate.
	* The function joins the given thread with the current thread by blocking
	* until the other thread has terminated.
	* @param thr The thread to join with.
	* @param res If this pointer is not NULL, the function will store the result
	*        code of the given thread in the integer pointed to by @c res.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int thrd_join(thrd_t thr, int* res);

	/** Put the calling thread to sleep.
	* Suspend execution of the calling thread.
	* @param duration  Interval to sleep for
	* @param remaining If non-NULL, this parameter will hold the remaining
	*                  time until time_point upon return. This will
	*                  typically be zero, but if the thread was woken up
	*                  by a signal that is not ignored before duration was
	*                  reached @c remaining will hold a positive time.
	* @return 0 (zero) on successful sleep, -1 if an interrupt occurred,
	*         or a negative value if the operation fails.
	*/
	[CLink] public static extern int thrd_sleep(timespec* duration, timespec* remaining);

	/** Yield execution to another thread.
	* Permit other threads to run, even if the current thread would ordinarily
	* continue to run.
	*/
	[CLink] public static extern void thrd_yield();

	/* Thread local storage */
	public struct tss_t;

	/** Destructor function for a thread-specific storage.
	* @param val The value of the destructed thread-specific storage.
	*/
	public function void tss_dtor_t(void* val);

	/** Create a thread-specific storage.
	* @param key The unique key identifier that will be set if the function is
	*        successful.
	* @param dtor Destructor function. This can be NULL.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	* @note On Windows, the @c dtor will definitely be called when
	* appropriate for threads created with @ref thrd_create.  It will be
	* called for other threads in most cases, the possible exception being
	* for DLLs loaded with LoadLibraryEx.  In order to be certain, you
	* should use @ref thrd_create whenever possible.
	*/
	[CLink] public static extern int tss_create(tss_t* key, tss_dtor_t dtor);

	/** Delete a thread-specific storage.
	* The function releases any resources used by the given thread-specific
	* storage.
	* @param key The key that shall be deleted.
	*/
	[CLink] public static extern void tss_delete(tss_t key);

	/** Get the value for a thread-specific storage.
	* @param key The thread-specific storage identifier.
	* @return The value for the current thread held in the given thread-specific
	* storage.
	*/
	[CLink] public static extern void* tss_get(tss_t key);

	/** Set the value for a thread-specific storage.
	* @param key The thread-specific storage identifier.
	* @param val The value of the thread-specific storage to set for the current
	*        thread.
	* @return @ref thrd_success on success, or @ref thrd_error if the request could
	* not be honored.
	*/
	[CLink] public static extern int tss_set(tss_t key, void* val);
}