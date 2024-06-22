const std = @import("std");
const tst = std.testing;
const builtin = @import("builtin");

pub const Str = []const u8;

fn strEql(a: Str, b: Str) bool {
    return std.mem.eql(u8, a, b);
}

fn strStartsWith(haystack: Str, needle: Str) bool {
    return std.mem.startsWith(u8, haystack, needle);
}

const Color = enum {
    black,
    white,

    const N = 2;
    const COLORS = [_]Color{ .black, .white };

    fn turn(self: @This()) @This() {
        return @enumFromInt(@intFromEnum(self) ^ 1);
    }

    fn toUsi(self: @This()) u8 {
        return "bw"[@intFromEnum(self)];
    }

    fn fromUsi(ch: u8) @This() {
        return if (ch == 'w') .white else .black;
    }
};

test "Color.turn" {
    try tst.expectEqual(Color.white, Color.black.turn());
    try tst.expectEqual(Color.black, Color.white.turn());
}

const File = enum {
    // zig fmt: off
    f1, f2, f3, f4, f5, f6, f7, f8, f9, none,
    // zig fmt: on

    const N = 9;
    const FILES_REV = [_]File{ .f9, .f8, .f7, .f6, .f5, .f4, .f3, .f2, .f1 };

    fn toUsi(self: @This()) u8 {
        return "1234567890"[@intFromEnum(self)];
    }

    fn fromUsi(ch: u8) @This() {
        return @enumFromInt(ch - '1');
    }
};

const Rank = enum {
    // zig fmt: off
    r1, r2, r3, r4, r5, r6, r7, r8, r9, none,
    // zig fmt: on

    const N = 9;
    const RANKS = [_]Rank{ .r1, .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9 };

    fn inTop(self: @This(), comptime US: Color, comptime R: comptime_int) bool {
        return if (US == .black)
            @intFromEnum(self) < R
        else
            @intFromEnum(self) > 8 - R;
    }

    fn toUsi(self: @This()) u8 {
        return "abcdefghi0"[@intFromEnum(self)];
    }

    fn fromUsi(ch: u8) @This() {
        return @enumFromInt(ch - 'a');
    }
};

test "Rank.inTop" {
    try tst.expectEqual(true, Rank.r3.inTop(.black, 3));
    try tst.expectEqual(false, Rank.r3.inTop(.white, 3));
    try tst.expectEqual(false, Rank.r7.inTop(.black, 3));
    try tst.expectEqual(true, Rank.r7.inTop(.white, 3));
}

const Square = enum {
    // zig fmt: off
    sq11, sq12, sq13, sq14, sq15, sq16, sq17, sq18, sq19,
    sq21, sq22, sq23, sq24, sq25, sq26, sq27, sq28, sq29,
    sq31, sq32, sq33, sq34, sq35, sq36, sq37, sq38, sq39,
    sq41, sq42, sq43, sq44, sq45, sq46, sq47, sq48, sq49,
    sq51, sq52, sq53, sq54, sq55, sq56, sq57, sq58, sq59,
    sq61, sq62, sq63, sq64, sq65, sq66, sq67, sq68, sq69,
    sq71, sq72, sq73, sq74, sq75, sq76, sq77, sq78, sq79,
    sq81, sq82, sq83, sq84, sq85, sq86, sq87, sq88, sq89,
    sq91, sq92, sq93, sq94, sq95, sq96, sq97, sq98, sq99,
    none,
    // zig fmt: on

    const N = 81;

    fn init(f: File, r: Rank) @This() {
        return @enumFromInt(@as(std.meta.Tag(@This()), @intFromEnum(f)) * Rank.N + @intFromEnum(r));
    }

    const FILES: [Square.N + 1]File = .{
        .f1,   .f1, .f1, .f1, .f1, .f1, .f1, .f1, .f1,
        .f2,   .f2, .f2, .f2, .f2, .f2, .f2, .f2, .f2,
        .f3,   .f3, .f3, .f3, .f3, .f3, .f3, .f3, .f3,
        .f4,   .f4, .f4, .f4, .f4, .f4, .f4, .f4, .f4,
        .f5,   .f5, .f5, .f5, .f5, .f5, .f5, .f5, .f5,
        .f6,   .f6, .f6, .f6, .f6, .f6, .f6, .f6, .f6,
        .f7,   .f7, .f7, .f7, .f7, .f7, .f7, .f7, .f7,
        .f8,   .f8, .f8, .f8, .f8, .f8, .f8, .f8, .f8,
        .f9,   .f9, .f9, .f9, .f9, .f9, .f9, .f9, .f9,
        .none,
    };

    fn file(self: @This()) File {
        return FILES[@intFromEnum(self)];
    }

    const RANKS: [Square.N + 1]Rank = .{
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .r1,   .r2, .r3, .r4, .r5, .r6, .r7, .r8, .r9,
        .none,
    };

    fn rank(self: @This()) Rank {
        return RANKS[@intFromEnum(self)];
    }

    fn front(self: @This(), comptime US: Color) @This() {
        std.debug.assert(!self.rank().inTop(US, 1));
        if (US == .black) {
            return @enumFromInt(@intFromEnum(self) - 1);
        } else {
            return @enumFromInt(@intFromEnum(self) + 1);
        }
    }

    fn right(self: @This()) @This() {
        std.debug.assert(self.file() != .f1);
        return @enumFromInt(@intFromEnum(self) - Rank.N);
    }

    fn left(self: @This()) @This() {
        std.debug.assert(self.file() != .f9);
        return @enumFromInt(@intFromEnum(self) + Rank.N);
    }
};

test "Square.front" {
    try tst.expectEqual(Square.sq54, Square.sq55.front(.black));
    try tst.expectEqual(Square.sq56, Square.sq55.front(.white));
}

test "Square.right" {
    try tst.expectEqual(Square.sq45, Square.sq55.right());
}

test "Square.left" {
    try tst.expectEqual(Square.sq65, Square.sq55.left());
}

const Direction = enum {
    right_up,
    right,
    right_down,
    up,
    down,
    left_up,
    left,
    left_down,
    none,

    const N = 8;
};

const PieceRaw = enum {
    // zig fmt: off
    none,
    r_pawn, r_lance, r_knight, r_silver, r_bishop, r_rook, r_gold,
    // zig fmt: on

    const N = 7;

    fn toUsi(self: @This()) u8 {
        return "0PLNSBRG"[@intFromEnum(self)];
    }

    fn fromUsi(ch: u8) @This() {
        return switch (ch) {
            'P' => .r_pawn,
            'L' => .r_lance,
            'N' => .r_knight,
            'S' => .r_silver,
            'B' => .r_bishop,
            'R' => .r_rook,
            'G' => .r_gold,
            else => .none,
        };
    }
};

const PieceType = enum {
    // zig fmt: off
    none,
    pawn, lance, knight, silver, bishop, rook, gold, king,
    pro_pawn, pro_lance, pro_knight, pro_silver, horse, dragon,
    golds, hdk, bishop_horse, rook_dragon, silver_hdk, golds_hdk,
    // zig fmt: on

    const N = 15;
    const N_TYPE_BB = 21;
};

const Piece = enum(u8) {
    // zig fmt: off
    none,
    b_pawn, b_lance, b_knight, b_silver, b_bishop, b_rook, b_gold, b_king,
    b_pro_pawn, b_pro_lance, b_pro_knight, b_pro_silver, b_horse, b_dragon,
    w_pawn = 17, w_lance, w_knight, w_silver, w_bishop, w_rook, w_gold,
    w_king, w_pro_pawn, w_pro_lance, w_pro_knight, w_pro_silver, w_horse, w_dragon,
    // zig fmt: on

    fn init(c: Color, pt: PieceType) @This() {
        return @enumFromInt((@as(u8, @intFromEnum(c)) << 4) + @intFromEnum(pt));
    }

    fn initPieceRaw(c: Color, pr: PieceRaw) @This() {
        return @enumFromInt((@as(u8, @intFromEnum(c)) << 4) + @intFromEnum(pr));
    }

    fn pieceRaw(self: @This()) PieceRaw {
        return @enumFromInt((@intFromEnum(self) & 0b00111));
    }

    fn pieceType(self: @This()) PieceType {
        return @enumFromInt((@intFromEnum(self) & 0b01111));
    }

    fn color(self: @This()) Color {
        return @enumFromInt((@intFromEnum(self) & 0b10000) >> 4);
    }

    fn promote(self: @This()) @This() {
        return @enumFromInt(@intFromEnum(self) | 0b01000);
    }

    const USI = [_]Str{
        "",   "P",  "L",  "N",  "S",  "B",  "R", "G",  "K",
        "+P", "+L", "+N", "+S", "+B", "+R", "",  "",   "p",
        "l",  "n",  "s",  "b",  "r",  "g",  "k", "+p", "+l",
        "+n", "+s", "+b", "+r",
    };

    fn toUsi(self: @This()) Str {
        return USI[@intFromEnum(self)];
    }

    fn fromUsi(ch: u8, promoted: bool) @This() {
        return if (promoted) switch (ch) {
            'P' => .b_pro_pawn,
            'L' => .b_pro_lance,
            'N' => .b_pro_knight,
            'S' => .b_pro_silver,
            'B' => .b_horse,
            'R' => .b_dragon,
            'p' => .w_pro_pawn,
            'l' => .w_pro_lance,
            'n' => .w_pro_knight,
            's' => .w_pro_silver,
            'b' => .w_horse,
            'r' => .w_dragon,
            else => .none,
        } else switch (ch) {
            'P' => .b_pawn,
            'L' => .b_lance,
            'N' => .b_knight,
            'S' => .b_silver,
            'B' => .b_bishop,
            'R' => .b_rook,
            'G' => .b_gold,
            'K' => .b_king,
            'p' => .w_pawn,
            'l' => .w_lance,
            'n' => .w_knight,
            's' => .w_silver,
            'b' => .w_bishop,
            'r' => .w_rook,
            'g' => .w_gold,
            'k' => .w_king,
            else => .none,
        };
    }
};

test "Piece.pieceRaw" {
    try tst.expectEqual(PieceRaw.r_pawn, Piece.b_pawn.pieceRaw());
    try tst.expectEqual(PieceRaw.r_pawn, Piece.w_pro_pawn.pieceRaw());
}

test "Piece.pieceType" {
    try tst.expectEqual(PieceType.pawn, Piece.b_pawn.pieceType());
    try tst.expectEqual(PieceType.pro_pawn, Piece.w_pro_pawn.pieceType());
}

test "Piece.color" {
    try tst.expectEqual(Color.black, Piece.b_pawn.color());
    try tst.expectEqual(Color.white, Piece.w_pro_pawn.color());
}

test "Piece.promote" {
    try tst.expectEqual(Piece.b_pro_pawn, Piece.b_pawn.promote());
    try tst.expectEqual(Piece.b_pro_pawn, Piece.b_pro_pawn.promote());
    try tst.expectEqual(Piece.w_dragon, Piece.w_rook.promote());
    try tst.expectEqual(Piece.w_dragon, Piece.w_dragon.promote());
}

const Bitboard = @Vector(2, u64);

fn bbInit(comptime I: comptime_int) Bitboard {
    return .{ @as(u63, @truncate(I)), @as(u18, @truncate(I >> 63)) };
}

fn bbShl(bb: Bitboard, B: comptime_int) Bitboard {
    return bb << @splat(B);
}

fn bbShr(bb: Bitboard, B: comptime_int) Bitboard {
    return bb >> @splat(B);
}

fn bbAny(bb: Bitboard) bool {
    return @reduce(.Or, bb != Bitboard{ 0, 0 });
}

fn bbPeek(bb: Bitboard) Square {
    std.debug.assert(bb[0] != 0 or bb[1] != 0);
    return @enumFromInt(if (bb[0] == 0) @ctz(bb[1]) + 63 else @ctz(bb[0]));
}

fn bbPop(bb: *Bitboard) Square {
    std.debug.assert(bb[0] != 0 or bb[1] != 0);
    var sq: Square = undefined;
    if (bb[0] != 0) {
        sq = @enumFromInt(@ctz(bb[0]));
        bb[0] &= bb[0] - 1;
    } else {
        sq = @enumFromInt(@ctz(bb[1]) + 63);
        bb[1] &= bb[1] - 1;
    }
    return sq;
}

test "bbPop" {
    var bb = bbInit(0b100000000_000000000_000000000_000000000_000010000_000000000_000000000_000000000_000000001);
    try tst.expectEqual(true, bbAny(bb));
    try tst.expectEqual(Square.sq11, bbPeek(bb));
    try tst.expectEqual(Square.sq11, bbPop(&bb));
    try tst.expectEqual(true, bbAny(bb));
    try tst.expectEqual(Square.sq55, bbPeek(bb));
    try tst.expectEqual(Square.sq55, bbPop(&bb));
    try tst.expectEqual(true, bbAny(bb));
    try tst.expectEqual(Square.sq99, bbPeek(bb));
    try tst.expectEqual(Square.sq99, bbPop(&bb));
    try tst.expectEqual(false, bbAny(bb));
}

fn bbFor(bb: Bitboard, closure: anytype) void {
    var p0 = bb[0];
    while (p0 != 0) {
        closure.call(@enumFromInt(@ctz(p0)));
        p0 &= p0 - 1;
    }
    var p1 = bb[1];
    while (p1 != 0) {
        closure.call(@enumFromInt(@ctz(p1) + 63));
        p1 &= p1 - 1;
    }
}

test "bbFor" {
    const bb = bbInit(0b100000000_000000000_000000000_000000000_000010000_000000000_000000000_000000000_000000001);
    var sum: usize = 0;
    bbFor(bb, &struct {
        sum: *usize,
        fn call(ctx: @This(), sq: Square) void {
            ctx.sum.* += @intFromEnum(sq);
        }
    }{ .sum = &sum });
    try tst.expectEqual(120, sum);
}

fn bbMoreThanOne(bb: Bitboard) bool {
    std.debug.assert(bb[0] & bb[1] == 0);
    return @popCount(bb[0] | bb[1]) > 1;
}

fn bbDecrement(bb: Bitboard) Bitboard {
    return bb -% @shuffle(
        u64,
        @intFromBool(bb == @Vector(2, u64){ 0, 0 }) | @Vector(2, u64){ 0, 1 },
        undefined,
        @Vector(2, i32){ 1, 0 },
    );
}

fn bbBitReverse(bb: Bitboard) Bitboard {
    return @shuffle(u64, @bitReverse(bb), undefined, @Vector(2, i32){ 1, 0 });
}

fn bbPositiveEffect(mask: Bitboard, occ: Bitboard) Bitboard {
    const blocker = mask & occ;
    return bbDecrement(blocker) ^ blocker & mask;
}

test "bbPositiveEffect" {
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_011100000_000000000_000000000_000000000_000000000),
        bbPositiveEffect(
            bbInit(0b000000000_000000000_000000000_000000000_111100000_000000000_000000000_000000000_000000000),
            bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000),
        ),
    );
}

fn bbNegativeEffect(mask: Bitboard, occ: Bitboard) Bitboard {
    const blocker = mask & occ;
    return bbBitReverse(bbDecrement(bbBitReverse(blocker))) ^ blocker & mask;
}

test "bbNegativeEffect" {
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001110_000000000_000000000_000000000_000000000),
        bbNegativeEffect(
            bbInit(0b000000000_000000000_000000000_000000000_000001111_000000000_000000000_000000000_000000000),
            bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000),
        ),
    );
}

const EMPTY_BB = bbInit(0);
const FULL_BB = bbInit((1 << 81) - 1);

const F1_BB = bbInit(0x1ff);
const F2_BB = bbInit(0x1ff << 9);
const F3_BB = bbInit(0x1ff << 18);
const F4_BB = bbInit(0x1ff << 27);
const F5_BB = bbInit(0x1ff << 36);
const F6_BB = bbInit(0x1ff << 45);
const F7_BB = bbInit(0x1ff << 54);
const F8_BB = bbInit(0x1ff << 63);
const F9_BB = bbInit(0x1ff << 72);
const FILE_BB: [File.N]Bitboard = .{ F1_BB, F2_BB, F3_BB, F4_BB, F5_BB, F6_BB, F7_BB, F8_BB, F9_BB };

fn fileBB(f: File) Bitboard {
    return FILE_BB[@intFromEnum(f)];
}

const R1_BB = bbInit(0x1008040201008040201);
const R2_BB = bbInit(0x1008040201008040201 << 1);
const R3_BB = bbInit(0x1008040201008040201 << 2);
const R4_BB = bbInit(0x1008040201008040201 << 3);
const R5_BB = bbInit(0x1008040201008040201 << 4);
const R6_BB = bbInit(0x1008040201008040201 << 5);
const R7_BB = bbInit(0x1008040201008040201 << 6);
const R8_BB = bbInit(0x1008040201008040201 << 7);
const R9_BB = bbInit(0x1008040201008040201 << 8);
const RANK_BB: [Rank.N]Bitboard = .{ R1_BB, R2_BB, R3_BB, R4_BB, R5_BB, R6_BB, R7_BB, R8_BB, R9_BB };

fn pawnDropMaskBB(comptime US: Color, pawns: Bitboard) Bitboard {
    const t = R9_BB - pawns;
    if (US == .black) {
        return R9_BB ^ (R9_BB - bbShr(t & R9_BB, 7));
    } else {
        return ~R9_BB & (R9_BB - bbShr(t & R9_BB, 8));
    }
}

test "pawnDropMaskBB" {
    try tst.expectEqual(
        bbInit(0b111111110_111111110_111111110_111111110_000000000_111111110_111111110_111111110_111111110),
        pawnDropMaskBB(.black, bbInit(0b000000000_000000000_000000000_000000000_000010000_000000000_000000000_000000000_000000000)),
    );
    try tst.expectEqual(
        bbInit(0b011111111_011111111_011111111_011111111_000000000_011111111_011111111_011111111_011111111),
        pawnDropMaskBB(.white, bbInit(0b000000000_000000000_000000000_000000000_000010000_000000000_000000000_000000000_000000000)),
    );
}

const SQUARE_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        tbl[sqi] = bbInit(1 << sqi);
    }
    break :_ tbl;
};

fn squareBB(sq: Square) Bitboard {
    return SQUARE_BB[@intFromEnum(sq)];
}

test "squareBB" {
    try tst.expectEqual(EMPTY_BB, squareBB(.none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000001),
        squareBB(.sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_100000000),
        squareBB(.sq19),
    );
    try tst.expectEqual(
        bbInit(0b000000001_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        squareBB(.sq91),
    );
    try tst.expectEqual(
        bbInit(0b100000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        squareBB(.sq99),
    );
}

const FORWARD_RANKS_BB: [Color.N][Rank.N]Bitboard = .{
    .{
        EMPTY_BB,
        R1_BB,
        R1_BB | R2_BB,
        R1_BB | R2_BB | R3_BB,
        R1_BB | R2_BB | R3_BB | R4_BB,
        R1_BB | R2_BB | R3_BB | R4_BB | R5_BB,
        R1_BB | R2_BB | R3_BB | R4_BB | R5_BB | R6_BB,
        R1_BB | R2_BB | R3_BB | R4_BB | R5_BB | R6_BB | R7_BB,
        R1_BB | R2_BB | R3_BB | R4_BB | R5_BB | R6_BB | R7_BB | R8_BB,
    },
    .{
        R9_BB | R8_BB | R7_BB | R6_BB | R5_BB | R4_BB | R3_BB | R2_BB,
        R9_BB | R8_BB | R7_BB | R6_BB | R5_BB | R4_BB | R3_BB,
        R9_BB | R8_BB | R7_BB | R6_BB | R5_BB | R4_BB,
        R9_BB | R8_BB | R7_BB | R6_BB | R5_BB,
        R9_BB | R8_BB | R7_BB | R6_BB,
        R9_BB | R8_BB | R7_BB,
        R9_BB | R8_BB,
        R9_BB,
        EMPTY_BB,
    },
};

fn topRanksBB(comptime US: Color, comptime R: comptime_int) Bitboard {
    if (US == .black) {
        return FORWARD_RANKS_BB[@intFromEnum(US)][R];
    } else {
        return FORWARD_RANKS_BB[@intFromEnum(US)][8 - R];
    }
}

test "topRanksBB" {
    try tst.expectEqual(
        bbInit(0b000000001_000000001_000000001_000000001_000000001_000000001_000000001_000000001_000000001),
        topRanksBB(.black, 1),
    );
    try tst.expectEqual(
        bbInit(0b000000111_000000111_000000111_000000111_000000111_000000111_000000111_000000111_000000111),
        topRanksBB(.black, 3),
    );
    try tst.expectEqual(
        bbInit(0b100000000_100000000_100000000_100000000_100000000_100000000_100000000_100000000_100000000),
        topRanksBB(.white, 1),
    );
    try tst.expectEqual(
        bbInit(0b111000000_111000000_111000000_111000000_111000000_111000000_111000000_111000000_111000000),
        topRanksBB(.white, 3),
    );
}

const FORWARD_FILE_BB = _: {
    var tbl: [Square.N + 1][Color.N]Bitboard = .{.{EMPTY_BB} ** Color.N} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        for (0..Color.N) |ci| {
            tbl[sqi][ci] = FORWARD_RANKS_BB[ci][@intFromEnum(sq.rank())] & FILE_BB[@intFromEnum(sq.file())];
        }
    }
    break :_ tbl;
};

fn forwardFileBB(comptime US: Color, sq: Square) Bitboard {
    return FORWARD_FILE_BB[@intFromEnum(sq)][@intFromEnum(US)];
}

test "forwardFileBB" {
    try tst.expectEqual(EMPTY_BB, forwardFileBB(.black, .none));
    try tst.expectEqual(EMPTY_BB, forwardFileBB(.black, .sq11));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001111_000000000_000000000_000000000_000000000),
        forwardFileBB(.black, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b011111111_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        forwardFileBB(.black, .sq99),
    );
    try tst.expectEqual(EMPTY_BB, forwardFileBB(.white, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_111111110),
        forwardFileBB(.white, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_111100000_000000000_000000000_000000000_000000000),
        forwardFileBB(.white, .sq55),
    );
    try tst.expectEqual(EMPTY_BB, forwardFileBB(.white, .sq99));
}

const ORTHOGONAL_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        tbl[sqi] = (FILE_BB[@intFromEnum(sq.file())] | RANK_BB[@intFromEnum(sq.rank())]) ^ SQUARE_BB[sqi];
    }
    break :_ tbl;
};

fn orthogonalBB(sq: Square) Bitboard {
    return ORTHOGONAL_BB[@intFromEnum(sq)];
}

test "orthogonalBB" {
    try tst.expectEqual(EMPTY_BB, orthogonalBB(.none));
    try tst.expectEqual(
        bbInit(0b000000001_000000001_000000001_000000001_000000001_000000001_000000001_000000001_111111110),
        orthogonalBB(.sq11),
    );
    try tst.expectEqual(
        bbInit(0b000010000_000010000_000010000_000010000_111101111_000010000_000010000_000010000_000010000),
        orthogonalBB(.sq55),
    );
    try tst.expectEqual(
        bbInit(0b011111111_100000000_100000000_100000000_100000000_100000000_100000000_100000000_100000000),
        orthogonalBB(.sq99),
    );
}

const INCLINE_BB: [17]Bitboard = .{
    bbInit(0b000000001_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b000000010_000000001_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b000000100_000000010_000000001_000000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b000001000_000000100_000000010_000000001_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b000010000_000001000_000000100_000000010_000000001_000000000_000000000_000000000_000000000),
    bbInit(0b000100000_000010000_000001000_000000100_000000010_000000001_000000000_000000000_000000000),
    bbInit(0b001000000_000100000_000010000_000001000_000000100_000000010_000000001_000000000_000000000),
    bbInit(0b010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000001_000000000),
    bbInit(0b100000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000001),
    bbInit(0b000000000_100000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010),
    bbInit(0b000000000_000000000_100000000_010000000_001000000_000100000_000010000_000001000_000000100),
    bbInit(0b000000000_000000000_000000000_100000000_010000000_001000000_000100000_000010000_000001000),
    bbInit(0b000000000_000000000_000000000_000000000_100000000_010000000_001000000_000100000_000010000),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_100000000_010000000_001000000_000100000),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_100000000_010000000_001000000),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_100000000_010000000),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_100000000),
};

fn inclineBB(sq: Square) Bitboard {
    return INCLINE_BB[@as(u32, 8) - @intFromEnum(sq.file()) + @intFromEnum(sq.rank())];
}

const DECLINE_BB: [17]Bitboard = .{
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000001),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000001_000000010),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000001_000000010_000000100),
    bbInit(0b000000000_000000000_000000000_000000000_000000000_000000001_000000010_000000100_000001000),
    bbInit(0b000000000_000000000_000000000_000000000_000000001_000000010_000000100_000001000_000010000),
    bbInit(0b000000000_000000000_000000000_000000001_000000010_000000100_000001000_000010000_000100000),
    bbInit(0b000000000_000000000_000000001_000000010_000000100_000001000_000010000_000100000_001000000),
    bbInit(0b000000000_000000001_000000010_000000100_000001000_000010000_000100000_001000000_010000000),
    bbInit(0b000000001_000000010_000000100_000001000_000010000_000100000_001000000_010000000_100000000),
    bbInit(0b000000010_000000100_000001000_000010000_000100000_001000000_010000000_100000000_000000000),
    bbInit(0b000000100_000001000_000010000_000100000_001000000_010000000_100000000_000000000_000000000),
    bbInit(0b000001000_000010000_000100000_001000000_010000000_100000000_000000000_000000000_000000000),
    bbInit(0b000010000_000100000_001000000_010000000_100000000_000000000_000000000_000000000_000000000),
    bbInit(0b000100000_001000000_010000000_100000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b001000000_010000000_100000000_000000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b010000000_100000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
    bbInit(0b100000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
};

fn declineBB(sq: Square) Bitboard {
    return DECLINE_BB[@as(u32, @intFromEnum(sq.file())) + @intFromEnum(sq.rank())];
}

const DIAGONAL_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        tbl[sqi] = (inclineBB(sq) | declineBB(sq)) ^ SQUARE_BB[sqi];
    }
    break :_ tbl;
};

fn diagonalBB(sq: Square) Bitboard {
    return DIAGONAL_BB[@intFromEnum(sq)];
}

test "diagonalBB" {
    try tst.expectEqual(EMPTY_BB, diagonalBB(.none));
    try tst.expectEqual(
        bbInit(0b100000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000000),
        diagonalBB(.sq11),
    );
    try tst.expectEqual(
        bbInit(0b100000001_010000010_001000100_000101000_000000000_000101000_001000100_010000010_100000001),
        diagonalBB(.sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000001),
        diagonalBB(.sq99),
    );
}

const ADJACENT_FILES_BB: [File.N]Bitboard = .{
    F1_BB | F2_BB,
    F1_BB | F2_BB | F3_BB,
    F2_BB | F3_BB | F4_BB,
    F3_BB | F4_BB | F5_BB,
    F4_BB | F5_BB | F6_BB,
    F5_BB | F6_BB | F7_BB,
    F6_BB | F7_BB | F8_BB,
    F7_BB | F8_BB | F9_BB,
    F8_BB | F9_BB,
};

const ADJACENT_RANKS_BB: [Rank.N]Bitboard = .{
    R1_BB | R2_BB,
    R1_BB | R2_BB | R3_BB,
    R2_BB | R3_BB | R4_BB,
    R3_BB | R4_BB | R5_BB,
    R4_BB | R5_BB | R6_BB,
    R5_BB | R6_BB | R7_BB,
    R6_BB | R7_BB | R8_BB,
    R7_BB | R8_BB | R9_BB,
    R8_BB | R9_BB,
};

const KING_EFFECT_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        tbl[sqi] = ADJACENT_FILES_BB[@intFromEnum(sq.file())] & ADJACENT_RANKS_BB[@intFromEnum(sq.rank())] ^ SQUARE_BB[sqi];
    }
    break :_ tbl;
};

fn kingEffectBB(sq: Square) Bitboard {
    return KING_EFFECT_BB[@intFromEnum(sq)];
}

test "kingEffectBB" {
    try tst.expectEqual(EMPTY_BB, kingEffectBB(.none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000011_000000010),
        kingEffectBB(.sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000111000_000101000_000111000_000000000_000000000_000000000),
        kingEffectBB(.sq55),
    );
    try tst.expectEqual(
        bbInit(0b010000000_110000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        kingEffectBB(.sq99),
    );
}

const PAWN_EFFECT_BB = _: {
    var tbl: [Square.N + 1][Color.N]Bitboard = .{.{EMPTY_BB} ** Color.N} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        for (0..Color.N) |ci| {
            tbl[sqi][ci] = FORWARD_FILE_BB[sqi][ci] & KING_EFFECT_BB[sqi];
        }
    }
    break :_ tbl;
};

fn pawnEffectBB(comptime US: Color, sq: Square) Bitboard {
    return PAWN_EFFECT_BB[@intFromEnum(sq)][@intFromEnum(US)];
}

test "pawnEffectBB" {
    try tst.expectEqual(EMPTY_BB, pawnEffectBB(.black, .none));
    try tst.expectEqual(EMPTY_BB, pawnEffectBB(.black, .sq11));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001000_000000000_000000000_000000000_000000000),
        pawnEffectBB(.black, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b010000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        pawnEffectBB(.black, .sq99),
    );
    try tst.expectEqual(EMPTY_BB, pawnEffectBB(.white, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000010),
        pawnEffectBB(.white, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000100000_000000000_000000000_000000000_000000000),
        pawnEffectBB(.white, .sq55),
    );
    try tst.expectEqual(EMPTY_BB, pawnEffectBB(.white, .sq99));
}

const KNIGHT_EFFECT_BB = _: {
    var tbl: [Square.N + 1][Color.N]Bitboard = .{.{EMPTY_BB} ** Color.N} ** (Square.N + 1);
    for (2..Rank.N) |ri| {
        for (0..File.N) |fi| {
            const sqi = @intFromEnum(Square.init(@enumFromInt(fi), @enumFromInt(ri)));
            tbl[sqi][0] = FORWARD_RANKS_BB[0][ri] & ADJACENT_FILES_BB[fi] & DIAGONAL_BB[sqi - 1];
        }
    }
    for (0..Rank.N - 2) |ri| {
        for (0..File.N) |fi| {
            const sqi = @intFromEnum(Square.init(@enumFromInt(fi), @enumFromInt(ri)));
            tbl[sqi][1] = FORWARD_RANKS_BB[1][ri] & ADJACENT_FILES_BB[fi] & DIAGONAL_BB[sqi + 1];
        }
    }
    break :_ tbl;
};

fn knightEffectBB(comptime US: Color, sq: Square) Bitboard {
    return KNIGHT_EFFECT_BB[@intFromEnum(sq)][@intFromEnum(US)];
}

test "knightEffectBB" {
    try tst.expectEqual(EMPTY_BB, knightEffectBB(.black, .none));
    try tst.expectEqual(EMPTY_BB, knightEffectBB(.black, .sq11));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000100_000000000_000000100_000000000_000000000_000000000),
        knightEffectBB(.black, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_001000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        knightEffectBB(.black, .sq99),
    );
    try tst.expectEqual(EMPTY_BB, knightEffectBB(.white, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000100_000000000),
        knightEffectBB(.white, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_001000000_000000000_001000000_000000000_000000000_000000000),
        knightEffectBB(.white, .sq55),
    );
    try tst.expectEqual(EMPTY_BB, knightEffectBB(.white, .sq99));
}

const SILVER_EFFECT_BB = _: {
    var tbl: [Square.N + 1][Color.N]Bitboard = .{.{EMPTY_BB} ** Color.N} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        for (0..Color.N) |ci| {
            tbl[sqi][ci] = (FORWARD_FILE_BB[sqi][ci] | DIAGONAL_BB[sqi]) & KING_EFFECT_BB[sqi];
        }
    }
    break :_ tbl;
};

fn silverEffectBB(comptime US: Color, sq: Square) Bitboard {
    return SILVER_EFFECT_BB[@intFromEnum(sq)][@intFromEnum(US)];
}

test "silverEffectBB" {
    try tst.expectEqual(EMPTY_BB, silverEffectBB(.black, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000010_000000000),
        silverEffectBB(.black, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000101000_000001000_000101000_000000000_000000000_000000000),
        silverEffectBB(.black, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b010000000_010000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        silverEffectBB(.black, .sq99),
    );
    try tst.expectEqual(EMPTY_BB, silverEffectBB(.white, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000010_000000010),
        silverEffectBB(.white, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000101000_000100000_000101000_000000000_000000000_000000000),
        silverEffectBB(.white, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        silverEffectBB(.white, .sq99),
    );
}

const GOLD_EFFECT_BB = _: {
    var tbl: [Square.N + 1][Color.N]Bitboard = .{.{EMPTY_BB} ** Color.N} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        for (0..Color.N) |ci| {
            tbl[sqi][ci] = (FORWARD_RANKS_BB[ci][@intFromEnum(sq.rank())] & DIAGONAL_BB[sqi] | ORTHOGONAL_BB[sqi]) & KING_EFFECT_BB[sqi];
        }
    }
    break :_ tbl;
};

fn goldEffectBB(comptime US: Color, sq: Square) Bitboard {
    return GOLD_EFFECT_BB[@intFromEnum(sq)][@intFromEnum(US)];
}

test "goldEffectBB" {
    try tst.expectEqual(EMPTY_BB, goldEffectBB(.black, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000001_000000010),
        goldEffectBB(.black, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000011000_000101000_000011000_000000000_000000000_000000000),
        goldEffectBB(.black, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b010000000_110000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        goldEffectBB(.black, .sq99),
    );
    try tst.expectEqual(EMPTY_BB, goldEffectBB(.white, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000011_000000010),
        goldEffectBB(.white, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000110000_000101000_000110000_000000000_000000000_000000000),
        goldEffectBB(.white, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b010000000_100000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        goldEffectBB(.white, .sq99),
    );
}

const NEGATIVE_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (1..Square.N) |sqi| {
        tbl[sqi] = bbDecrement(SQUARE_BB[sqi]);
    }
    break :_ tbl;
};

const POSITIVE_BB = _: {
    var tbl: [Square.N + 1]Bitboard = .{EMPTY_BB} ** (Square.N + 1);
    for (0..Square.N - 1) |sqi| {
        tbl[sqi] = ~NEGATIVE_BB[sqi] & FULL_BB ^ SQUARE_BB[sqi];
    }
    break :_ tbl;
};

const DIRECTION_BB = _: {
    @setEvalBranchQuota(2000);
    var tbl: [Square.N + 1][Direction.N]Bitboard = .{.{EMPTY_BB} ** Direction.N} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        const sq: Square = @enumFromInt(sqi);
        tbl[sqi][@intFromEnum(Direction.right_up)] = inclineBB(sq) & NEGATIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.right)] = RANK_BB[@intFromEnum(sq.rank())] & NEGATIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.right_down)] = declineBB(sq) & NEGATIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.up)] = FILE_BB[@intFromEnum(sq.file())] & NEGATIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.down)] = FILE_BB[@intFromEnum(sq.file())] & POSITIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.left_up)] = declineBB(sq) & POSITIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.left)] = RANK_BB[@intFromEnum(sq.rank())] & POSITIVE_BB[sqi];
        tbl[sqi][@intFromEnum(Direction.left_down)] = inclineBB(sq) & POSITIVE_BB[sqi];
    }
    break :_ tbl;
};

fn directionBB(comptime D: Direction, sq: Square) Bitboard {
    return DIRECTION_BB[@intFromEnum(sq)][@intFromEnum(D)];
}

test "directionBB" {
    try tst.expectEqual(EMPTY_BB, directionBB(.right_up, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000001000_000000100_000000010_000000001),
        directionBB(.right_up, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000010000_000010000_000010000_000010000),
        directionBB(.right, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000100000_001000000_010000000_100000000),
        directionBB(.right_down, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001111_000000000_000000000_000000000_000000000),
        directionBB(.up, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_111100000_000000000_000000000_000000000_000000000),
        directionBB(.down, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000001_000000010_000000100_000001000_000000000_000000000_000000000_000000000_000000000),
        directionBB(.left_up, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000010000_000010000_000010000_000010000_000000000_000000000_000000000_000000000_000000000),
        directionBB(.left, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b100000000_010000000_001000000_000100000_000000000_000000000_000000000_000000000_000000000),
        directionBB(.left_down, .sq55),
    );
}

fn directionEffectBB(d: Direction, sq: Square, occ: Bitboard) Bitboard {
    return switch (d) {
        .right_up => bbNegativeEffect(directionBB(.right_up, sq), occ),
        .right => bbNegativeEffect(directionBB(.right, sq), occ),
        .right_down => bbNegativeEffect(directionBB(.right_down, sq), occ),
        .up => bbNegativeEffect(directionBB(.up, sq), occ),
        .down => bbPositiveEffect(directionBB(.down, sq), occ),
        .left_up => bbPositiveEffect(directionBB(.left_up, sq), occ),
        .left => bbPositiveEffect(directionBB(.left, sq), occ),
        .left_down => bbPositiveEffect(directionBB(.left_down, sq), occ),
        else => EMPTY_BB,
    };
}

test "directionEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000001000_000000100_000000010_000000000),
        directionEffectBB(.right_up, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000010000_000010000_000010000_000000000),
        directionEffectBB(.right, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000100000_001000000_010000000_000000000),
        directionEffectBB(.right_down, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001110_000000000_000000000_000000000_000000000),
        directionEffectBB(.up, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_011100000_000000000_000000000_000000000_000000000),
        directionEffectBB(.down, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000010_000000100_000001000_000000000_000000000_000000000_000000000_000000000),
        directionEffectBB(.left_up, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000010000_000010000_000010000_000000000_000000000_000000000_000000000_000000000),
        directionEffectBB(.left, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000000_001000000_000100000_000000000_000000000_000000000_000000000_000000000),
        directionEffectBB(.left_down, .sq55, occ),
    );
}

fn lanceEffectBB(comptime US: Color, sq: Square, occ: Bitboard) Bitboard {
    return if (US == .black)
        bbNegativeEffect(directionBB(.up, sq), occ)
    else
        bbPositiveEffect(directionBB(.down, sq), occ);
}

test "lanceEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(EMPTY_BB, lanceEffectBB(.black, .none, occ));
    try tst.expectEqual(EMPTY_BB, lanceEffectBB(.black, .sq11, occ));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001110_000000000_000000000_000000000_000000000),
        lanceEffectBB(.black, .sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b011111111_000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        lanceEffectBB(.black, .sq99, occ),
    );
    try tst.expectEqual(EMPTY_BB, lanceEffectBB(.white, .none, occ));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000_111111110),
        lanceEffectBB(.white, .sq11, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_011100000_000000000_000000000_000000000_000000000),
        lanceEffectBB(.white, .sq55, occ),
    );
    try tst.expectEqual(EMPTY_BB, lanceEffectBB(.white, .sq99, occ));
}

const Bitboard256 = @Vector(4, u64);

fn bb256Double(bb: Bitboard) Bitboard256 {
    return @shuffle(u64, bb, undefined, @Vector(4, i32){ 0, 1, 0, 1 });
}

fn bb256Join(bb1: Bitboard, bb2: Bitboard) Bitboard256 {
    return @shuffle(u64, bb1, bb2, @Vector(4, i32){ 0, 1, ~@as(i32, 0), ~@as(i32, 1) });
}

fn bb256Decrement(bb256: Bitboard256) Bitboard256 {
    return bb256 -% @shuffle(
        u64,
        @intFromBool(bb256 == @Vector(4, u64){ 0, 0, 0, 0 }) | @Vector(4, u64){ 0, 1, 0, 1 },
        undefined,
        @Vector(4, i32){ 1, 0, 3, 2 },
    );
}

fn bb256BitReverse(bb256: Bitboard256) Bitboard256 {
    return @shuffle(u64, @bitReverse(bb256), undefined, @Vector(4, i32){ 1, 0, 3, 2 });
}

fn bb256Merge(bb256: Bitboard256) Bitboard {
    return .{ bb256[0] | bb256[2], bb256[1] | bb256[3] };
}

fn bb256PositiveEffect(mask256: Bitboard256, occ256: Bitboard256) Bitboard {
    const blocker256 = mask256 & occ256;
    return bb256Merge((bb256Decrement(blocker256) ^ blocker256) & mask256);
}

test "bb256PositiveEffect" {
    const mask256 = bb256Join(directionBB(.left_up, .sq55), directionBB(.left_down, .sq55));
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    const occ256 = bb256Double(occ);
    try tst.expectEqual(
        bbInit(0b000000000_010000010_001000100_000101000_000000000_000000000_000000000_000000000_000000000),
        bb256PositiveEffect(mask256, occ256),
    );
}

fn bb256NegativeEffect(mask256: Bitboard256, occ256: Bitboard256) Bitboard {
    const blocker256 = mask256 & occ256;
    return bb256Merge((bb256BitReverse(bb256Decrement(bb256BitReverse(blocker256))) ^ blocker256) & mask256);
}

test "bb256NegativeEffect" {
    const mask256 = bb256Join(directionBB(.right_up, .sq55), directionBB(.right_down, .sq55));
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    const occ256 = bb256Double(occ);
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000101000_001000100_010000010_000000000),
        bb256NegativeEffect(mask256, occ256),
    );
}

const ROOK_POSITIVE_MASK_BB = _: {
    var tbl: [Square.N + 1]Bitboard256 = .{.{ 0, 0, 0, 0 }} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        tbl[sqi] = bb256Join(directionBB(.left, @enumFromInt(sqi)), directionBB(.down, @enumFromInt(sqi)));
    }
    break :_ tbl;
};

const ROOK_NEGATIVE_MASK_BB = _: {
    var tbl: [Square.N + 1]Bitboard256 = .{.{ 0, 0, 0, 0 }} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        tbl[sqi] = bb256Join(directionBB(.right, @enumFromInt(sqi)), directionBB(.up, @enumFromInt(sqi)));
    }
    break :_ tbl;
};

fn rookEffectBB(sq: Square, occ: Bitboard) Bitboard {
    const occ256 = bb256Double(occ);
    return bb256PositiveEffect(ROOK_POSITIVE_MASK_BB[@intFromEnum(sq)], occ256) |
        bb256NegativeEffect(ROOK_NEGATIVE_MASK_BB[@intFromEnum(sq)], occ256);
}

test "rookEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(EMPTY_BB, rookEffectBB(.none, occ));
    try tst.expectEqual(
        bbInit(0b000000001_000000001_000000001_000000001_000000001_000000001_000000001_000000001_111111110),
        rookEffectBB(.sq11, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000010000_000010000_000010000_011101110_000010000_000010000_000010000_000000000),
        rookEffectBB(.sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b011111111_100000000_100000000_100000000_100000000_100000000_100000000_100000000_100000000),
        rookEffectBB(.sq99, occ),
    );
}

fn dragonEffectBB(sq: Square, occ: Bitboard) Bitboard {
    return rookEffectBB(sq, occ) | kingEffectBB(sq);
}

test "dragonEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(EMPTY_BB, dragonEffectBB(.none, occ));
    try tst.expectEqual(
        bbInit(0b000000001_000000001_000000001_000000001_000000001_000000001_000000001_000000011_111111110),
        dragonEffectBB(.sq11, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000010000_000010000_000111000_011101110_000111000_000010000_000010000_000000000),
        dragonEffectBB(.sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b011111111_110000000_100000000_100000000_100000000_100000000_100000000_100000000_100000000),
        dragonEffectBB(.sq99, occ),
    );
}

const BISHOP_POSITIVE_MASK_BB = _: {
    var tbl: [Square.N + 1]Bitboard256 = .{.{ 0, 0, 0, 0 }} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        tbl[sqi] = bb256Join(directionBB(.left_up, @enumFromInt(sqi)), directionBB(.left_down, @enumFromInt(sqi)));
    }
    break :_ tbl;
};

const BISHOP_NEGATIVE_MASK_BB = _: {
    var tbl: [Square.N + 1]Bitboard256 = .{.{ 0, 0, 0, 0 }} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        tbl[sqi] = bb256Join(directionBB(.right_up, @enumFromInt(sqi)), directionBB(.right_down, @enumFromInt(sqi)));
    }
    break :_ tbl;
};

fn bishopEffectBB(sq: Square, occ: Bitboard) Bitboard {
    const occ256 = bb256Double(occ);
    return bb256PositiveEffect(BISHOP_POSITIVE_MASK_BB[@intFromEnum(sq)], occ256) |
        bb256NegativeEffect(BISHOP_NEGATIVE_MASK_BB[@intFromEnum(sq)], occ256);
}

test "bishopEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(EMPTY_BB, bishopEffectBB(.none, occ));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000010_000000000),
        bishopEffectBB(.sq11, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000010_001000100_000101000_000000000_000101000_001000100_010000010_000000000),
        bishopEffectBB(.sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        bishopEffectBB(.sq99, occ),
    );
}

fn horseEffectBB(sq: Square, occ: Bitboard) Bitboard {
    return bishopEffectBB(sq, occ) | kingEffectBB(sq);
}

test "horseEffectBB" {
    const occ = bbInit(0b000000000_010010010_000000000_000000000_010010010_000000000_000000000_010010010_000000000);
    try tst.expectEqual(EMPTY_BB, horseEffectBB(.none, occ));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000000000_000000000_000000011_000000010),
        horseEffectBB(.sq11, occ),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000010_001000100_000111000_000101000_000111000_001000100_010000010_000000000),
        horseEffectBB(.sq55, occ),
    );
    try tst.expectEqual(
        bbInit(0b010000000_110000000_000000000_000000000_000000000_000000000_000000000_000000000_000000000),
        horseEffectBB(.sq99, occ),
    );
}

fn pieceEffectBB(pc: Piece, sq: Square, occ: Bitboard) Bitboard {
    return switch (pc) {
        .b_pawn => pawnEffectBB(.black, sq),
        .b_lance => lanceEffectBB(.black, sq, occ),
        .b_knight => knightEffectBB(.black, sq),
        .b_silver => silverEffectBB(.black, sq),
        .b_gold, .b_pro_pawn, .b_pro_lance, .b_pro_knight, .b_pro_silver => goldEffectBB(.black, sq),
        .w_pawn => pawnEffectBB(.white, sq),
        .w_lance => lanceEffectBB(.white, sq, occ),
        .w_knight => knightEffectBB(.white, sq),
        .w_silver => silverEffectBB(.white, sq),
        .w_gold, .w_pro_pawn, .w_pro_lance, .w_pro_knight, .w_pro_silver => goldEffectBB(.white, sq),
        .b_bishop, .w_bishop => bishopEffectBB(sq, occ),
        .b_rook, .w_rook => rookEffectBB(sq, occ),
        .b_king, .w_king => kingEffectBB(sq),
        .b_horse, .w_horse => horseEffectBB(sq, occ),
        .b_dragon, .w_dragon => dragonEffectBB(sq, occ),
        else => FULL_BB,
    };
}

const SQUARES_DIRECTION = _: {
    @setEvalBranchQuota(16000);
    var tbl: [Square.N + 1][Square.N + 1]Direction = .{.{Direction.none} ** (Square.N + 1)} ** (Square.N + 1);
    for (0..Square.N) |sqi| {
        for (0..Direction.N) |di| {
            var bb = DIRECTION_BB[sqi][di];
            while (bbAny(bb)) {
                tbl[sqi][@intFromEnum(bbPop(&bb))] = @enumFromInt(di);
            }
        }
    }
    break :_ tbl;
};

fn squaresDirection(sq1: Square, sq2: Square) Direction {
    return SQUARES_DIRECTION[@intFromEnum(sq1)][@intFromEnum(sq2)];
}

test "squaresDirection" {
    try tst.expectEqual(Direction.none, squaresDirection(.none, .none));
    try tst.expectEqual(Direction.right_up, squaresDirection(.sq55, .sq11));
    try tst.expectEqual(Direction.right, squaresDirection(.sq55, .sq15));
    try tst.expectEqual(Direction.right_down, squaresDirection(.sq55, .sq19));
    try tst.expectEqual(Direction.up, squaresDirection(.sq55, .sq51));
    try tst.expectEqual(Direction.none, squaresDirection(.sq55, .sq55));
    try tst.expectEqual(Direction.down, squaresDirection(.sq55, .sq59));
    try tst.expectEqual(Direction.left_up, squaresDirection(.sq55, .sq91));
    try tst.expectEqual(Direction.left, squaresDirection(.sq55, .sq95));
    try tst.expectEqual(Direction.left_down, squaresDirection(.sq55, .sq99));
}

fn squaresAligned(from: Square, to: Square, ksq: Square) bool {
    const d = squaresDirection(from, ksq);
    return if (d != .none) d == squaresDirection(to, ksq) else false;
}

test "squaresAligned" {
    try tst.expectEqual(false, squaresAligned(.sq11, .sq15, .none));
    try tst.expectEqual(true, squaresAligned(.sq11, .sq15, .sq19));
    try tst.expectEqual(true, squaresAligned(.sq15, .sq11, .sq19));
    try tst.expectEqual(false, squaresAligned(.sq11, .sq51, .sq19));
    try tst.expectEqual(false, squaresAligned(.sq11, .sq19, .sq15));
}

const BETWEEN_BB = _: {
    @setEvalBranchQuota(32000);
    var tbl: [Square.N + 1][Square.N + 1]Bitboard = .{.{EMPTY_BB} ** (Square.N + 1)} ** (Square.N + 1);
    for (0..Square.N) |sqi1| {
        const sq1: Square = @enumFromInt(sqi1);
        for (0..Square.N) |sqi2| {
            const sq2: Square = @enumFromInt(sqi2);
            const d = squaresDirection(sq1, sq2);
            if (d == .none) {
                continue;
            }
            tbl[sqi1][sqi2] = directionBB(d, sq1) & directionBB(squaresDirection(sq2, sq1), sq2);
        }
    }
    break :_ tbl;
};

fn betweenBB(sq1: Square, sq2: Square) Bitboard {
    return BETWEEN_BB[@intFromEnum(sq1)][@intFromEnum(sq2)];
}

test "betweenBB" {
    try tst.expectEqual(EMPTY_BB, betweenBB(.sq55, .none));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000001000_000000100_000000010_000000000),
        betweenBB(.sq55, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000010000_000010000_000010000_000000000),
        betweenBB(.sq55, .sq15),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000000000_000100000_001000000_010000000_000000000),
        betweenBB(.sq55, .sq19),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_000001110_000000000_000000000_000000000_000000000),
        betweenBB(.sq55, .sq51),
    );
    try tst.expectEqual(EMPTY_BB, betweenBB(.sq55, .sq55));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_011100000_000000000_000000000_000000000_000000000),
        betweenBB(.sq55, .sq59),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000010_000000100_000001000_000000000_000000000_000000000_000000000_000000000),
        betweenBB(.sq55, .sq91),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000010000_000010000_000010000_000000000_000000000_000000000_000000000_000000000),
        betweenBB(.sq55, .sq95),
    );
    try tst.expectEqual(
        bbInit(0b000000000_010000000_001000000_000100000_000000000_000000000_000000000_000000000_000000000),
        betweenBB(.sq55, .sq99),
    );
}

const LINE_BB = _: {
    @setEvalBranchQuota(16000);
    var tbl: [Square.N + 1][Square.N + 1]Bitboard = .{.{EMPTY_BB} ** (Square.N + 1)} ** (Square.N + 1);
    for (0..Square.N) |sqi1| {
        const sq1: Square = @enumFromInt(sqi1);
        for (0..Square.N) |sqi2| {
            const sq2: Square = @enumFromInt(sqi2);
            const d = squaresDirection(sq1, sq2);
            tbl[sqi1][sqi2] = switch (d) {
                .right_up, .left_down => inclineBB(sq1),
                .right, .left => RANK_BB[@intFromEnum(sq1.rank())],
                .right_down, .left_up => declineBB(sq1),
                .up, .down => FILE_BB[@intFromEnum(sq1.file())],
                else => EMPTY_BB,
            };
        }
    }
    break :_ tbl;
};

fn lineBB(sq1: Square, sq2: Square) Bitboard {
    return LINE_BB[@intFromEnum(sq1)][@intFromEnum(sq2)];
}

test "lineBB" {
    try tst.expectEqual(EMPTY_BB, lineBB(.sq55, .none));
    try tst.expectEqual(
        bbInit(0b100000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000001),
        lineBB(.sq55, .sq11),
    );
    try tst.expectEqual(
        bbInit(0b000010000_000010000_000010000_000010000_000010000_000010000_000010000_000010000_000010000),
        lineBB(.sq55, .sq15),
    );
    try tst.expectEqual(
        bbInit(0b000000001_000000010_000000100_000001000_000010000_000100000_001000000_010000000_100000000),
        lineBB(.sq55, .sq19),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_111111111_000000000_000000000_000000000_000000000),
        lineBB(.sq55, .sq51),
    );
    try tst.expectEqual(EMPTY_BB, lineBB(.sq55, .sq55));
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_111111111_000000000_000000000_000000000_000000000),
        lineBB(.sq55, .sq59),
    );
    try tst.expectEqual(
        bbInit(0b000000001_000000010_000000100_000001000_000010000_000100000_001000000_010000000_100000000),
        lineBB(.sq55, .sq91),
    );
    try tst.expectEqual(
        bbInit(0b000010000_000010000_000010000_000010000_000010000_000010000_000010000_000010000_000010000),
        lineBB(.sq55, .sq95),
    );
    try tst.expectEqual(
        bbInit(0b100000000_010000000_001000000_000100000_000010000_000001000_000000100_000000010_000000001),
        lineBB(.sq55, .sq99),
    );
}

const CHECK_CANDIDATE_BB = _: {
    @setEvalBranchQuota(64000);
    var tbl = std.mem.zeroes([Square.N + 1][PieceRaw.N][Color.N]Bitboard);
    for (Color.COLORS) |US| {
        const THEM = US.turn();
        const ENEMY_BB = topRanksBB(US, 3);
        for (0..Square.N) |ksqi| {
            const ksq: Square = @enumFromInt(ksqi);
            const enemy_gold = ENEMY_BB & goldEffectBB(THEM, ksq);
            var candidates = EMPTY_BB;
            var to_bb = pawnEffectBB(THEM, ksq);
            while (bbAny(to_bb)) {
                candidates |= pawnEffectBB(THEM, bbPop(&to_bb));
            }
            to_bb = enemy_gold;
            while (bbAny(to_bb)) {
                candidates |= pawnEffectBB(THEM, bbPop(&to_bb));
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_pawn) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            candidates = forwardFileBB(THEM, ksq);
            if (bbAny(ENEMY_BB & squareBB(ksq))) {
                if (ksq.file() != .f1) {
                    candidates |= forwardFileBB(THEM, ksq.right());
                }
                if (ksq.file() != .f9) {
                    candidates |= forwardFileBB(THEM, ksq.left());
                }
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_lance) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            candidates = EMPTY_BB;
            to_bb = knightEffectBB(THEM, ksq) | enemy_gold;
            while (bbAny(to_bb)) {
                candidates |= knightEffectBB(THEM, bbPop(&to_bb));
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_knight) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            candidates = EMPTY_BB;
            to_bb = silverEffectBB(THEM, ksq);
            while (bbAny(to_bb)) {
                candidates |= silverEffectBB(THEM, bbPop(&to_bb));
            }
            to_bb = enemy_gold;
            while (bbAny(to_bb)) {
                candidates |= silverEffectBB(THEM, bbPop(&to_bb));
            }
            to_bb = goldEffectBB(THEM, ksq);
            while (bbAny(to_bb)) {
                candidates |= ENEMY_BB & silverEffectBB(THEM, bbPop(&to_bb));
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_silver) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            candidates = EMPTY_BB;
            to_bb = diagonalBB(ksq);
            while (bbAny(to_bb)) {
                candidates |= diagonalBB(bbPop(&to_bb));
            }
            to_bb = ENEMY_BB & kingEffectBB(ksq);
            while (bbAny(to_bb)) {
                candidates |= diagonalBB(bbPop(&to_bb));
            }
            to_bb = kingEffectBB(ksq);
            while (bbAny(to_bb)) {
                candidates |= ENEMY_BB & diagonalBB(bbPop(&to_bb));
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_bishop) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            // 飛、龍はどのマスからでも王手できるので省略し、飛の位置には馬の王手候補を格納する。
            candidates = EMPTY_BB;
            to_bb = horseEffectBB(ksq, EMPTY_BB);
            while (bbAny(to_bb)) {
                candidates |= horseEffectBB(bbPop(&to_bb), EMPTY_BB);
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_rook) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);

            candidates = EMPTY_BB;
            to_bb = goldEffectBB(THEM, ksq);
            while (bbAny(to_bb)) {
                candidates |= goldEffectBB(THEM, bbPop(&to_bb));
            }
            tbl[ksqi][@intFromEnum(PieceRaw.r_gold) - 1][@intFromEnum(US)] = candidates & ~squareBB(ksq);
        }
    }
    break :_ tbl;
};

// 飛を指定した場合、馬の王手候補を返す。
fn checkCandidateBB(comptime US: Color, comptime PR: PieceRaw, sq: Square) Bitboard {
    return CHECK_CANDIDATE_BB[@intFromEnum(sq)][@intFromEnum(PR) - 1][@intFromEnum(US)];
}

test "checkCandidateBB" {
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000110_000000100_000000110_000000000_000000000_000000000),
        checkCandidateBB(.black, .r_pawn, .sq51),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_000000000_001000000_000000000_000000000_000000000_000000000),
        checkCandidateBB(.black, .r_pawn, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000000_111111110_111111110_111111110_000000000_000000000_000000000),
        checkCandidateBB(.black, .r_lance, .sq51),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000011100_000001000_000011100_000001000_000011100_000000000_000000000),
        checkCandidateBB(.black, .r_knight, .sq51),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_000000111_000000111_000000110_000000111_000000111_000000000_000000000),
        checkCandidateBB(.black, .r_silver, .sq51),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_001010100_001010100_001000100_001010100_001010100_000000000_000000000),
        checkCandidateBB(.black, .r_silver, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b000000000_000000000_001110000_001111000_001100100_001111000_001110000_000000000_000000000),
        checkCandidateBB(.black, .r_gold, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b101111101_010111110_101011111_010101111_101010110_010101111_101011111_010111110_101111101),
        checkCandidateBB(.black, .r_bishop, .sq51),
    );
    try tst.expectEqual(
        bbInit(0b101010111_010101111_101010111_010101110_101000101_010101110_101010111_010101111_101010111),
        checkCandidateBB(.black, .r_bishop, .sq55),
    );
    try tst.expectEqual(
        bbInit(0b111010111_111101111_111111111_011111110_101101101_011111110_111111111_111101111_111010111),
        checkCandidateBB(.black, .r_rook, .sq55),
    );
}

const Move = u32;
const MOVE_DROPPED: Move = 1 << 14;
const MOVE_PROMOTED: Move = 1 << 15;
const MOVE_NONE: Move = 0;

fn moveTo(m: Move) Square {
    return @enumFromInt(m & 0x7f);
}

fn moveSetTo(m: Move, to: Square) Move {
    std.debug.assert(moveTo(m) == .sq11);
    return m + @intFromEnum(to);
}

fn moveDropped(m: Move) bool {
    return m & MOVE_DROPPED != 0;
}

fn moveDropPieceRaw(m: Move) PieceRaw {
    return @enumFromInt((m >> 7) & 0x7f);
}

fn moveFrom(m: Move) Square {
    return @enumFromInt((m >> 7) & 0x7f);
}

fn movePromoted(m: Move) bool {
    return m & MOVE_PROMOTED != 0;
}

fn moveAfterPiece(m: Move) Piece {
    return @enumFromInt(m >> 16);
}

fn moveBeforePiece(m: Move) Piece {
    return @enumFromInt((m >> 16) ^ ((m & MOVE_PROMOTED) >> 12));
}

fn moveInit(from: Square, to: Square, before_piece: Piece) Move {
    return @intFromEnum(to) + (@as(Move, @intFromEnum(from)) << 7) +
        (@as(Move, @intFromEnum(before_piece)) << 16);
}

test "moveInit" {
    const m = moveInit(.sq24, .sq23, .b_pawn);
    try tst.expectEqual(Square.sq23, moveTo(m));
    try tst.expectEqual(false, moveDropped(m));
    try tst.expectEqual(Square.sq24, moveFrom(m));
    try tst.expectEqual(false, movePromoted(m));
    try tst.expectEqual(Piece.b_pawn, moveAfterPiece(m));
    try tst.expectEqual(Piece.b_pawn, moveBeforePiece(m));
}

fn moveInitPromote(from: Square, to: Square, before_piece: Piece) Move {
    return @intFromEnum(to) + (@as(Move, @intFromEnum(from)) << 7) + MOVE_PROMOTED +
        (@as(Move, @intFromEnum(before_piece.promote())) << 16);
}

test "moveInitPromote" {
    const m = moveInitPromote(.sq24, .sq23, .b_pawn);
    try tst.expectEqual(Square.sq23, moveTo(m));
    try tst.expectEqual(false, moveDropped(m));
    try tst.expectEqual(Square.sq24, moveFrom(m));
    try tst.expectEqual(true, movePromoted(m));
    try tst.expectEqual(Piece.b_pro_pawn, moveAfterPiece(m));
    try tst.expectEqual(Piece.b_pawn, moveBeforePiece(m));
}

fn moveInitDrop(to: Square, before_piece: Piece) Move {
    return @intFromEnum(to) + (@as(Move, @intFromEnum(before_piece.pieceRaw())) << 7) + MOVE_DROPPED +
        (@as(Move, @intFromEnum(before_piece)) << 16);
}

test "moveInitDrop" {
    const m = moveInitDrop(.sq23, .b_pawn);
    try tst.expectEqual(Square.sq23, moveTo(m));
    try tst.expectEqual(true, moveDropped(m));
    try tst.expectEqual(PieceRaw.r_pawn, moveDropPieceRaw(m));
    try tst.expectEqual(Piece.b_pawn, moveAfterPiece(m));
    try tst.expectEqual(Piece.b_pawn, moveBeforePiece(m));
}

fn moveWriteUsi(m: Move, writer: anytype) !void {
    if (m == MOVE_NONE) {
        try writer.print("resign", .{});
    } else if (moveDropped(m)) {
        try writer.print("{c}*{c}{c}", .{ moveAfterPiece(m).pieceRaw().toUsi(), moveTo(m).file().toUsi(), moveTo(m).rank().toUsi() });
    } else {
        try writer.print("{c}{c}{c}{c}", .{ moveFrom(m).file().toUsi(), moveFrom(m).rank().toUsi(), moveTo(m).file().toUsi(), moveTo(m).rank().toUsi() });
        if (movePromoted(m)) {
            try writer.writeByte('+');
        }
    }
}

const Hand = u32;
const HAND_EMPTY: Hand = 0;
const HAND_SHIFT = [_]u5{ 0, 0, 8, 12, 16, 20, 24, 28 };
const HAND_MASK = [_]Hand{
    0,
    0b00000000_00000000_00000000_11111111,
    0b00000000_00000000_00001111_00000000,
    0b00000000_00000000_11110000_00000000,
    0b00000000_00001111_00000000_00000000,
    0b00000000_11110000_00000000_00000000,
    0b00001111_00000000_00000000_00000000,
    0b11110000_00000000_00000000_00000000,
};
const HAND_ONE = [_]Hand{
    0,
    0b00000000_00000000_00000000_00000001,
    0b00000000_00000000_00000001_00000000,
    0b00000000_00000000_00010000_00000000,
    0b00000000_00000001_00000000_00000000,
    0b00000000_00010000_00000000_00000000,
    0b00000001_00000000_00000000_00000000,
    0b00010000_00000000_00000000_00000000,
};
const HAND_PIECE_RAWS = [_]PieceRaw{ .r_rook, .r_bishop, .r_gold, .r_silver, .r_knight, .r_lance, .r_pawn };

fn handCount(h: Hand, pr: PieceRaw) u8 {
    return @truncate((h & HAND_MASK[@intFromEnum(pr)]) >> HAND_SHIFT[@intFromEnum(pr)]);
}

fn handAny(h: Hand, pr: PieceRaw) bool {
    return h & HAND_MASK[@intFromEnum(pr)] != 0;
}

fn handEmptyExceptPawns(h: Hand) bool {
    return h & 0b11111111_11111111_11111111_00000000 == 0;
}

fn handAdd(h: *Hand, pr: PieceRaw, d: u8) void {
    h.* += HAND_ONE[@intFromEnum(pr)] * d;
}

fn handIncrement(h: *Hand, pr: PieceRaw) void {
    h.* += HAND_ONE[@intFromEnum(pr)];
}

fn handDecrement(h: *Hand, pr: PieceRaw) void {
    h.* -= HAND_ONE[@intFromEnum(pr)];
}

test "Hand" {
    var h: Hand = HAND_EMPTY;
    try tst.expectEqual(0, handCount(h, .r_pawn));
    try tst.expectEqual(false, handAny(h, .r_pawn));
    try tst.expectEqual(0, handCount(h, .r_gold));
    try tst.expectEqual(false, handAny(h, .r_gold));
    try tst.expectEqual(true, handEmptyExceptPawns(h));
    handAdd(&h, .r_pawn, 18);
    try tst.expectEqual(18, handCount(h, .r_pawn));
    try tst.expectEqual(true, handAny(h, .r_pawn));
    try tst.expectEqual(0, handCount(h, .r_gold));
    try tst.expectEqual(false, handAny(h, .r_gold));
    try tst.expectEqual(true, handEmptyExceptPawns(h));
    handIncrement(&h, .r_gold);
    try tst.expectEqual(18, handCount(h, .r_pawn));
    try tst.expectEqual(true, handAny(h, .r_pawn));
    try tst.expectEqual(1, handCount(h, .r_gold));
    try tst.expectEqual(true, handAny(h, .r_gold));
    try tst.expectEqual(false, handEmptyExceptPawns(h));
    handDecrement(&h, .r_gold);
    try tst.expectEqual(18, handCount(h, .r_pawn));
    try tst.expectEqual(true, handAny(h, .r_pawn));
    try tst.expectEqual(0, handCount(h, .r_gold));
    try tst.expectEqual(false, handAny(h, .r_gold));
    try tst.expectEqual(true, handEmptyExceptPawns(h));
}

const Value = i32;
const VALUE_NONE: Value = 32002;
const VALUE_INFINITE: Value = 32001;

const PAWN_VALUE: Value = 90;
const LANCE_VALUE: Value = 315;
const KNIGHT_VALUE: Value = 405;
const SILVER_VALUE: Value = 495;
const GOLD_VALUE: Value = 540;
const BISHOP_VALUE: Value = 855;
const ROOK_VALUE: Value = 990;
const PRO_PAWN_VALUE: Value = 540;
const PRO_LANCE_VALUE: Value = 540;
const PRO_KNIGHT_VALUE: Value = 540;
const PRO_SILVER_VALUE: Value = 540;
const HORSE_VALUE: Value = 945;
const DRAGON_VALUE: Value = 1395;
const KING_VALUE: Value = 15000;

const PIECE_VALUE = [_]Value{
    0,                 PAWN_VALUE,      LANCE_VALUE,      KNIGHT_VALUE,
    SILVER_VALUE,      BISHOP_VALUE,    ROOK_VALUE,       GOLD_VALUE,
    KING_VALUE,        PRO_PAWN_VALUE,  PRO_LANCE_VALUE,  PRO_KNIGHT_VALUE,
    PRO_SILVER_VALUE,  HORSE_VALUE,     DRAGON_VALUE,     0,
    0,                 -PAWN_VALUE,     -LANCE_VALUE,     -KNIGHT_VALUE,
    -SILVER_VALUE,     -BISHOP_VALUE,   -ROOK_VALUE,      -GOLD_VALUE,
    -KING_VALUE,       -PRO_PAWN_VALUE, -PRO_LANCE_VALUE, -PRO_KNIGHT_VALUE,
    -PRO_SILVER_VALUE, -HORSE_VALUE,    -DRAGON_VALUE,    0,
};

fn pieceValue(pc: Piece) Value {
    return PIECE_VALUE[@intFromEnum(pc)];
}

const CAPTURED_PIECE_VALUE = [_]Value{
    0,                               PAWN_VALUE * 2,              LANCE_VALUE * 2,               KNIGHT_VALUE * 2,
    SILVER_VALUE * 2,                BISHOP_VALUE * 2,            ROOK_VALUE * 2,                GOLD_VALUE * 2,
    0,                               PRO_PAWN_VALUE + PAWN_VALUE, PRO_LANCE_VALUE + LANCE_VALUE, PRO_KNIGHT_VALUE + KNIGHT_VALUE,
    PRO_SILVER_VALUE + SILVER_VALUE, HORSE_VALUE + BISHOP_VALUE,  DRAGON_VALUE + ROOK_VALUE,     0,
    0,                               PAWN_VALUE * 2,              LANCE_VALUE * 2,               KNIGHT_VALUE * 2,
    SILVER_VALUE * 2,                BISHOP_VALUE * 2,            ROOK_VALUE * 2,                GOLD_VALUE * 2,
    0,                               PRO_PAWN_VALUE + PAWN_VALUE, PRO_LANCE_VALUE + LANCE_VALUE, PRO_KNIGHT_VALUE + KNIGHT_VALUE,
    PRO_SILVER_VALUE + SILVER_VALUE, HORSE_VALUE + BISHOP_VALUE,  DRAGON_VALUE + ROOK_VALUE,     0,
};

fn capturedPieceValue(pc: Piece) Value {
    return CAPTURED_PIECE_VALUE[@intFromEnum(pc)];
}

const PRO_DIFF_PIECE_VALUE = [_]Value{
    0,                               PRO_PAWN_VALUE - PAWN_VALUE, PRO_LANCE_VALUE - LANCE_VALUE, PRO_KNIGHT_VALUE - KNIGHT_VALUE,
    PRO_SILVER_VALUE - SILVER_VALUE, HORSE_VALUE - BISHOP_VALUE,  DRAGON_VALUE - ROOK_VALUE,     0,
    0,                               PRO_PAWN_VALUE - PAWN_VALUE, PRO_LANCE_VALUE - LANCE_VALUE, PRO_KNIGHT_VALUE - KNIGHT_VALUE,
    PRO_SILVER_VALUE - SILVER_VALUE, HORSE_VALUE - BISHOP_VALUE,  DRAGON_VALUE - ROOK_VALUE,     0,
    0,                               PRO_PAWN_VALUE - PAWN_VALUE, PRO_LANCE_VALUE - LANCE_VALUE, PRO_KNIGHT_VALUE - KNIGHT_VALUE,
    PRO_SILVER_VALUE - SILVER_VALUE, HORSE_VALUE - BISHOP_VALUE,  DRAGON_VALUE - ROOK_VALUE,     0,
    0,                               PRO_PAWN_VALUE - PAWN_VALUE, PRO_LANCE_VALUE - LANCE_VALUE, PRO_KNIGHT_VALUE - KNIGHT_VALUE,
    PRO_SILVER_VALUE - SILVER_VALUE, HORSE_VALUE - BISHOP_VALUE,  DRAGON_VALUE - ROOK_VALUE,     0,
};

fn proDiffPieceValue(pc: Piece) Value {
    return PRO_DIFF_PIECE_VALUE[@intFromEnum(pc)];
}

const StateInfo = struct {
    previous: ?*StateInfo = null,
    captured_piece: Piece = .none,
    checkers_bb: Bitboard = EMPTY_BB,
    blockers_bb: [Color.N]Bitboard = .{EMPTY_BB} ** Color.N,
    pinners_bb: [Color.N]Bitboard = .{EMPTY_BB} ** Color.N,
    check_squares_bb: [PieceType.N]Bitboard = .{EMPTY_BB} ** PieceType.N,
    material_value: Value = 0,

    const DEFAULT = StateInfo{};

    fn clear(self: *@This()) void {
        self.* = DEFAULT;
    }
};

test "StateInfo.clear" {
    var st = StateInfo{};
    st.captured_piece = .b_pawn;
    st.clear();
    try tst.expectEqual(Piece.none, st.captured_piece);
}

const Position = struct {
    board: [Square.N]Piece = .{Piece.none} ** Square.N,
    hands: [Color.N]Hand = .{HAND_EMPTY} ** Color.N,
    side_to_move: Color = .black,
    game_ply: usize = 0,
    by_color_bb: [Color.N]Bitboard = .{EMPTY_BB} ** Color.N,
    by_type_bb: [PieceType.N_TYPE_BB]Bitboard = .{EMPTY_BB} ** PieceType.N_TYPE_BB,
    king_squares: [Color.N]Square = .{Square.none} ** Color.N,
    state: *StateInfo = undefined,

    const DEFAULT = Position{};

    fn clear(self: *@This()) void {
        self.* = DEFAULT;
    }

    fn piece(self: @This(), sq: Square) Piece {
        return self.board[@intFromEnum(sq)];
    }

    fn xorPiece(self: *@This(), sq: Square, pc: Piece) void {
        self.by_color_bb[@intFromEnum(pc.color())] ^= squareBB(sq);
        self.by_type_bb[@intFromEnum(PieceType.none)] ^= squareBB(sq);
        self.by_type_bb[@intFromEnum(pc.pieceType())] ^= squareBB(sq);
    }

    fn putPiece(self: *@This(), sq: Square, pc: Piece) void {
        self.board[@intFromEnum(sq)] = pc;
        self.xorPiece(sq, pc);
    }

    fn removePiece(self: *@This(), sq: Square) void {
        const pc = self.piece(sq);
        self.board[@intFromEnum(sq)] = .none;
        self.xorPiece(sq, pc);
    }

    fn colorBB(self: @This(), comptime US: Color) Bitboard {
        return self.by_color_bb[@intFromEnum(US)];
    }

    fn typeBB(self: @This(), comptime PT: PieceType) Bitboard {
        return self.by_type_bb[@intFromEnum(PT)];
    }

    fn colorTypeBB(self: @This(), comptime US: Color, comptime PT: PieceType) Bitboard {
        return self.colorBB(US) & self.typeBB(PT);
    }

    fn occBB(self: @This()) Bitboard {
        return self.by_type_bb[@intFromEnum(PieceType.none)];
    }

    fn spacesBB(self: @This()) Bitboard {
        return self.occBB() ^ FULL_BB;
    }

    fn kingSquare(self: @This(), comptime US: Color) Square {
        return self.king_squares[@intFromEnum(US)];
    }

    fn blockersBB(self: @This(), comptime US: Color) Bitboard {
        return self.state.blockers_bb[@intFromEnum(US)];
    }

    fn checkersBB(self: @This()) Bitboard {
        return self.state.checkers_bb;
    }

    fn inCheck(self: @This()) bool {
        return bbAny(self.checkersBB());
    }

    fn checkSquaresBB(self: @This(), pt: PieceType) Bitboard {
        return self.state.check_squares_bb[@intFromEnum(pt)];
    }

    fn attackersTo(self: @This(), comptime US: Color, sq: Square, occ: Bitboard) Bitboard {
        const THEM = comptime US.turn();
        return (pawnEffectBB(THEM, sq) & self.typeBB(.pawn) |
            (knightEffectBB(THEM, sq) & self.typeBB(.knight)) |
            (silverEffectBB(THEM, sq) & self.typeBB(.silver_hdk)) |
            (goldEffectBB(THEM, sq) & self.typeBB(.golds_hdk)) |
            (bishopEffectBB(sq, occ) & self.typeBB(.bishop_horse)) |
            (rookEffectBB(sq, occ) & (self.typeBB(.lance) & forwardFileBB(THEM, sq) | self.typeBB(.rook_dragon)))) &
            self.colorBB(US);
    }

    fn updateBitboards(self: *@This()) void {
        self.by_type_bb[@intFromEnum(PieceType.golds)] =
            self.typeBB(.gold) |
            self.typeBB(.pro_pawn) |
            self.typeBB(.pro_lance) |
            self.typeBB(.pro_knight) |
            self.typeBB(.pro_silver);
        self.by_type_bb[@intFromEnum(PieceType.hdk)] =
            self.typeBB(.horse) |
            self.typeBB(.dragon) |
            self.typeBB(.king);
        self.by_type_bb[@intFromEnum(PieceType.bishop_horse)] =
            self.typeBB(.bishop) |
            self.typeBB(.horse);
        self.by_type_bb[@intFromEnum(PieceType.rook_dragon)] =
            self.typeBB(.rook) |
            self.typeBB(.dragon);
        self.by_type_bb[@intFromEnum(PieceType.silver_hdk)] =
            self.typeBB(.silver) |
            self.typeBB(.hdk);
        self.by_type_bb[@intFromEnum(PieceType.golds_hdk)] =
            self.typeBB(.golds) |
            self.typeBB(.hdk);
    }

    fn updateKingSquares(self: *@This()) void {
        inline for (Color.COLORS) |C| {
            const bb = self.colorTypeBB(C, .king);
            self.king_squares[@intFromEnum(C)] = if (bbAny(bb)) bbPeek(bb) else .none;
        }
    }

    fn updateBlockers(self: *@This(), comptime US: Color) void {
        const THEM = comptime US.turn();
        const ksq = self.kingSquare(US);
        self.state.blockers_bb[@intFromEnum(US)] = EMPTY_BB;
        self.state.pinners_bb[@intFromEnum(THEM)] = EMPTY_BB;
        var snipers =
            (self.typeBB(.rook_dragon) & orthogonalBB(ksq) |
            (self.typeBB(.bishop_horse) & diagonalBB(ksq)) |
            (self.typeBB(.lance) & forwardFileBB(US, ksq))) &
            self.colorBB(THEM);
        const occ = self.occBB() ^ snipers;
        while (bbAny(snipers)) {
            const sq = bbPop(&snipers);
            const bb = betweenBB(sq, ksq) & occ;
            if (bbAny(bb) and !bbMoreThanOne(bb)) {
                self.state.blockers_bb[@intFromEnum(US)] |= bb;
                if (bbAny(bb & self.colorBB(US))) {
                    self.state.pinners_bb[@intFromEnum(THEM)] |= squareBB(sq);
                }
            }
        }
    }

    fn updateCheckInfo(self: *@This(), comptime US: Color) void {
        const THEM = comptime US.turn();
        self.updateBlockers(US);
        self.updateBlockers(THEM);
        const ksq = self.kingSquare(THEM);
        const occ = self.occBB();
        const bbb = bishopEffectBB(ksq, occ);
        const rbb = rookEffectBB(ksq, occ);
        const gbb = goldEffectBB(THEM, ksq);
        const kbb = kingEffectBB(ksq);
        self.state.check_squares_bb[@intFromEnum(PieceType.pawn)] = pawnEffectBB(THEM, ksq);
        self.state.check_squares_bb[@intFromEnum(PieceType.lance)] = rbb & forwardFileBB(THEM, ksq);
        self.state.check_squares_bb[@intFromEnum(PieceType.knight)] = knightEffectBB(THEM, ksq);
        self.state.check_squares_bb[@intFromEnum(PieceType.silver)] = silverEffectBB(THEM, ksq);
        self.state.check_squares_bb[@intFromEnum(PieceType.bishop)] = bbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.rook)] = rbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.gold)] = gbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.king)] = EMPTY_BB;
        self.state.check_squares_bb[@intFromEnum(PieceType.pro_pawn)] = gbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.pro_lance)] = gbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.pro_knight)] = gbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.pro_silver)] = gbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.horse)] = bbb | kbb;
        self.state.check_squares_bb[@intFromEnum(PieceType.dragon)] = rbb | kbb;
    }

    fn updateState(self: *@This(), comptime US: Color) void {
        const THEM = comptime US.turn();
        self.state.checkers_bb = self.attackersTo(THEM, self.kingSquare(US), self.occBB());
        self.updateCheckInfo(US);
    }

    fn setSfen(self: *@This(), sfen: Str, st: *StateInfo) void {
        self.clear();
        st.clear();
        self.state = st;
        var i: usize = 0;
        var fi: u8 = File.N - 1;
        var ri: u8 = 0;
        var promoted = false;
        while (i < sfen.len) : (i += 1) {
            const ch = sfen[i];
            if (ch == ' ') {
                i += 1;
                break;
            } else if (std.ascii.isDigit(ch)) {
                fi -|= @truncate(ch - '0');
            } else if (ch == '/') {
                fi = File.N - 1;
                ri += 1;
            } else if (ch == '+') {
                promoted = true;
            } else {
                const pc = Piece.fromUsi(ch, promoted);
                if (pc != .none) {
                    self.putPiece(Square.init(@enumFromInt(fi), @enumFromInt(ri)), pc);
                    fi -|= 1;
                    promoted = false;
                }
            }
        }
        self.updateBitboards();
        self.updateKingSquares();
        if (i < sfen.len) {
            self.side_to_move = Color.fromUsi(sfen[i]);
            i += 2;
        }
        var hand_count: u8 = 0;
        while (i < sfen.len) : (i += 1) {
            const ch = sfen[i];
            if (ch == '-') {
                i += 2;
                break;
            } else if (ch == ' ') {
                i += 1;
                break;
            } else if (std.ascii.isDigit(ch)) {
                hand_count = (ch - '0') + hand_count * 10;
            } else {
                const pc = Piece.fromUsi(ch, false);
                if (pc != .none) {
                    handAdd(&self.hands[@intFromEnum(pc.color())], pc.pieceRaw(), @max(hand_count, 1));
                    hand_count = 0;
                }
            }
        }
        if (i < sfen.len) {
            self.game_ply = std.fmt.parseUnsigned(usize, sfen[i..], 10) catch 0;
        }
        if (self.side_to_move == .black) {
            self.updateState(.black);
        } else {
            self.updateState(.white);
        }
        self.state.material_value = 0;
        for (0..Square.N) |sqi| {
            self.state.material_value += pieceValue(self.board[sqi]);
        }
        for (Color.COLORS) |c| {
            for (HAND_PIECE_RAWS) |pr| {
                self.state.material_value += pieceValue(Piece.initPieceRaw(c, pr)) * handCount(self.hands[@intFromEnum(c)], pr);
            }
        }
    }

    fn fromSfen(sfen: Str, st: *StateInfo) @This() {
        var self = @This(){};
        self.setSfen(sfen, st);
        return self;
    }

    fn moveFromUsi(self: @This(), move_usi: Str) Move {
        const to = Square.init(File.fromUsi(move_usi[2]), Rank.fromUsi(move_usi[3]));
        if (move_usi[1] == '*') {
            return moveInitDrop(to, Piece.initPieceRaw(self.side_to_move, PieceRaw.fromUsi(move_usi[0])));
        }
        const from = Square.init(File.fromUsi(move_usi[0]), Rank.fromUsi(move_usi[1]));
        const before_pc = self.piece(from);
        if (move_usi.len > 4) {
            return moveInitPromote(from, to, before_pc);
        }
        return moveInit(from, to, before_pc);
    }

    fn toSfen(self: @This(), writer: anytype) !void {
        for (0..Rank.N) |ri| {
            var fi: isize = File.N - 1;
            while (fi >= 0) : (fi -= 1) {
                var empty_count: usize = 0;
                var pc: Piece = .none;
                while (fi >= 0) : (fi -= 1) {
                    pc = self.piece(Square.init(@enumFromInt(fi), @enumFromInt(ri)));
                    if (pc == .none) {
                        empty_count += 1;
                    } else {
                        break;
                    }
                }
                if (empty_count != 0) {
                    try writer.print("{d}", .{empty_count});
                }
                if (pc != .none) {
                    try writer.print("{s}", .{pc.toUsi()});
                }
            }
            if (ri < Rank.N - 1) {
                try writer.writeByte('/');
            }
        }
        try writer.print(" {c} ", .{self.side_to_move.toUsi()});
        var found = false;
        for (0..Color.N) |ci| {
            for (HAND_PIECE_RAWS) |pr| {
                const n = handCount(self.hands[ci], pr);
                if (n > 0) {
                    if (n > 1) {
                        try writer.print("{d}", .{n});
                    }
                    try writer.print("{s}", .{Piece.initPieceRaw(@enumFromInt(ci), pr).toUsi()});
                    found = true;
                }
            }
        }
        if (!found) {
            try writer.writeByte('-');
        }
        try writer.print(" {d}", .{self.game_ply});
    }

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (Rank.RANKS) |r| {
            for (File.FILES_REV) |f| {
                const pc = self.piece(Square.init(f, r));
                try writer.print("{s:2}", .{if (pc == .none) "." else pc.toUsi()});
            }
            try writer.writeByte('\n');
        }
        try self.toSfen(writer);
    }

    fn givesCheck(self: @This(), comptime US: Color, m: Move) bool {
        const THEM = comptime US.turn();
        const to = moveTo(m);
        if (bbAny(squareBB(to) & self.checkSquaresBB(moveAfterPiece(m).pieceType()))) {
            return true;
        }
        if (moveDropped(m)) {
            return false;
        }
        const from = moveFrom(m);
        return bbAny(squareBB(from) & self.blockersBB(THEM)) and !squaresAligned(from, to, self.kingSquare(THEM));
    }

    fn doMoveImpl(self: *@This(), comptime US: Color, comptime GIVES_CHECK: bool, m: Move, st: *StateInfo) void {
        const THEM = comptime US.turn();
        const prev_st = self.state;
        st.previous = prev_st;
        self.state = st;
        self.game_ply += 1;
        const to = moveTo(m);
        const after_pc = moveAfterPiece(m);
        var material_diff: Value = 0;
        if (moveDropped(m)) {
            self.putPiece(to, after_pc);
            handDecrement(&self.hands[@intFromEnum(US)], after_pc.pieceRaw());
            self.state.captured_piece = .none;
            if (GIVES_CHECK) {
                self.state.checkers_bb = squareBB(to);
            } else {
                self.state.checkers_bb = EMPTY_BB;
            }
            self.updateBitboards();
        } else {
            const from = moveFrom(m);
            const from_pc = self.piece(from);
            if (from_pc.pieceType() == .king) {
                self.king_squares[@intFromEnum(US)] = to;
            }
            if (movePromoted(m)) {
                material_diff = proDiffPieceValue(from_pc);
            }
            self.removePiece(from);
            const captured_pc = self.piece(to);
            if (captured_pc != .none) {
                self.removePiece(to);
                handIncrement(&self.hands[@intFromEnum(US)], captured_pc.pieceRaw());
                self.state.captured_piece = captured_pc;
                material_diff += capturedPieceValue(captured_pc);
            } else {
                self.state.captured_piece = .none;
            }
            self.putPiece(to, after_pc);
            self.updateBitboards();
            if (GIVES_CHECK) {
                self.state.checkers_bb = squareBB(to) & prev_st.check_squares_bb[@intFromEnum(after_pc.pieceType())];
                const ksq = self.kingSquare(THEM);
                if (bbAny(squareBB(from) & prev_st.blockers_bb[@intFromEnum(THEM)]) and !squaresAligned(from, to, ksq)) {
                    self.state.checkers_bb |= self.colorBB(US) & directionEffectBB(squaresDirection(ksq, from), from, self.occBB());
                }
            } else {
                self.state.checkers_bb = EMPTY_BB;
            }
        }
        self.state.material_value = prev_st.material_value + (if (US == .black) material_diff else -material_diff);
        self.side_to_move = THEM;
        self.updateCheckInfo(THEM);
    }

    fn doMove(self: *@This(), m: Move, st: *StateInfo) void {
        if (self.side_to_move == .black) {
            if (self.givesCheck(.black, m)) {
                self.doMoveImpl(.black, true, m, st);
            } else {
                self.doMoveImpl(.black, false, m, st);
            }
        } else {
            if (self.givesCheck(.white, m)) {
                self.doMoveImpl(.white, true, m, st);
            } else {
                self.doMoveImpl(.white, false, m, st);
            }
        }
    }

    fn undoMoveImpl(self: *@This(), comptime US: Color, m: Move) void {
        self.removePiece(moveTo(m));
        if (moveDropped(m)) {
            handIncrement(&self.hands[@intFromEnum(US)], moveDropPieceRaw(m));
        } else {
            const from = moveFrom(m);
            self.putPiece(from, moveBeforePiece(m));
            if (self.state.captured_piece != .none) {
                self.putPiece(moveTo(m), self.state.captured_piece);
                handDecrement(&self.hands[@intFromEnum(US)], self.state.captured_piece.pieceRaw());
            }
            if (moveAfterPiece(m).pieceType() == .king) {
                self.king_squares[@intFromEnum(US)] = from;
            }
        }
        self.updateBitboards();
        self.side_to_move = US;
        self.state = self.state.previous.?;
        self.game_ply -= 1;
    }

    fn undoMove(self: *@This(), m: Move) void {
        if (self.side_to_move == .black) {
            self.undoMoveImpl(.white, m);
        } else {
            self.undoMoveImpl(.black, m);
        }
    }

    fn isPawnDropMate(self: @This(), comptime US: Color, to: Square) bool {
        const THEM = comptime US.turn();
        const occ = self.occBB();
        if (!bbAny(self.attackersTo(US, to, occ))) {
            return false;
        }
        const hd_bb = self.typeBB(.horse) | self.typeBB(.dragon);
        const enemy_bb =
            (self.typeBB(.knight) & knightEffectBB(THEM, to) |
            ((self.typeBB(.silver) | hd_bb) & silverEffectBB(THEM, to)) |
            ((self.typeBB(.golds) | hd_bb) & goldEffectBB(THEM, to)) |
            (self.typeBB(.bishop_horse) & bishopEffectBB(to, occ)) |
            (self.typeBB(.rook_dragon) & rookEffectBB(to, occ))) &
            self.colorBB(THEM);
        if (bbAny(enemy_bb & (fileBB(to.file()) | ~self.blockersBB(THEM)))) {
            return false;
        }
        const escape_occ = squareBB(to) ^ occ;
        var escape_bb = ~self.colorBB(THEM) & kingEffectBB(self.kingSquare(THEM)) ^ squareBB(to);
        while (bbAny(escape_bb)) {
            const sq = bbPop(&escape_bb);
            if (!bbAny(self.attackersTo(US, sq, escape_occ))) {
                return false;
            }
        }
        return true;
    }

    fn isPawnDropValid(self: @This(), comptime US: Color, to: Square) bool {
        const THEM = comptime US.turn();
        return !(bbAny(self.colorTypeBB(US, .pawn) & fileBB(to.file())) or
            (@reduce(.And, pawnEffectBB(US, to) == squareBB(self.kingSquare(THEM))) and self.isPawnDropMate(US, to)));
    }

    fn isMoveEvasive(self: @This(), comptime US: Color, m: Move) bool {
        std.debug.assert(self.inCheck());
        if (moveAfterPiece(m).pieceType() != .king) {
            var checkers = self.checkersBB();
            const csq = bbPop(&checkers);
            if (bbAny(checkers)) {
                return false;
            }
            const to = moveTo(m);
            if (to == csq) {
                return true;
            }
            if (!bbAny(betweenBB(csq, self.kingSquare(US)) & squareBB(to))) {
                return false;
            }
        }
        return true;
    }

    fn isMoveSafe(self: @This(), comptime US: Color, m: Move) bool {
        if (moveDropped(m)) {
            return true;
        }
        const to = moveTo(m);
        const ksq = self.kingSquare(US);
        if (ksq == moveFrom(m)) {
            const THEM = comptime US.turn();
            return !bbAny(self.attackersTo(THEM, to, self.occBB() ^ squareBB(ksq)));
        }
        const from = moveFrom(m);
        return !bbAny(self.blockersBB(US) & squareBB(from)) or squaresAligned(from, to, ksq);
    }
};

pub const DEFAULT_SFEN = "lnsgkgsnl/1r5b1/ppppppppp/9/9/9/PPPPPPPPP/1B5R1/LNSGKGSNL b - 1";
pub const MATSURI_SFEN = "l6nl/5+P1gk/2np1S3/p1p4Pp/3P2Sp1/1PPb2P1P/P5GS1/R8/LN4bKL w RGgsn5p 1";
const DROPS_SFEN = "9/9/4k4/9/9/9/9/9/8P b RBGSNLP 1";
const MAX_MOVES_SFEN = "R8/2K1S1SSk/4B4/9/9/9/9/9/1L1L1L3 b RBGSNLP3g3n17p 1";
const PAWN_DROP_MATE_SFEN = "6Rsk/9/7S1/9/9/9/9/9/9 b P 1";
const EVASIONS_SFEN = "9/4l4/5G3/4KB+r2/9/9/9/9/9 b P 1";
const CAPTURES_SFEN = "9/9/3pp4/3GPP3/9/9/9/9/9 b - 1";
const MAX_CHECKS_SFEN = "+B7+B/7R1/2R6/9/3Sk1G2/6G2/3+PS1+P2/9/4L1N1K b GSNLPgs2n2l15p 1";
const DOUBLE_CHECKED_SFEN = "9/9/2k1r4/5+B3/4K1r2/9/6B2/9/9 b P 1";

test "Position.fromSfen" {
    const sfen = MATSURI_SFEN;
    var st = StateInfo{};
    const pos = Position.fromSfen(sfen, &st);
    var list = std.ArrayList(u8).init(tst.allocator);
    defer list.deinit();
    try pos.toSfen(list.writer());
    try tst.expectEqualStrings(sfen, list.items);
}

test "Position.moveFromUsi" {
    var st = StateInfo{};
    const pos = Position.fromSfen(MATSURI_SFEN, &st);
    try tst.expectEqual(moveInitDrop(.sq28, .w_gold), pos.moveFromUsi("G*2h"));
    try tst.expectEqual(moveInit(.sq39, .sq28, .w_bishop), pos.moveFromUsi("3i2h"));
    try tst.expectEqual(moveInitPromote(.sq39, .sq28, .w_bishop), pos.moveFromUsi("3i2h+"));
}

test "Position.givesCheck" {
    const data_list = [_]struct {
        move: Move,
        check: bool,
    }{
        .{ .move = moveInitDrop(.sq52, .b_pawn), .check = true },
        .{ .move = moveInitDrop(.sq62, .b_pawn), .check = false },
        .{ .move = moveInit(.sq53, .sq52, .b_gold), .check = true },
        .{ .move = moveInit(.sq53, .sq54, .b_gold), .check = false },
        .{ .move = moveInit(.sq53, .sq63, .b_gold), .check = true },
    };
    var st = StateInfo{};
    var pos = Position.fromSfen("4k4/9/4G4/9/9/9/9/9/4L4 b P 1", &st);
    for (data_list) |data| {
        try tst.expectEqual(data.check, pos.givesCheck(.black, data.move));
    }
}

test "Position.doMove" {
    const data_list = [_]struct {
        move: Move,
        sfen: Str,
        material_value: Value,
    }{
        .{
            .move = moveInit(.sq77, .sq76, .b_pawn),
            .sfen = "lnsgkgsnl/1r5b1/ppppppppp/9/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL w - 2",
            .material_value = 0,
        },
        .{
            .move = moveInit(.sq33, .sq34, .w_pawn),
            .sfen = "lnsgkgsnl/1r5b1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/1B5R1/LNSGKGSNL b - 3",
            .material_value = 0,
        },
        .{
            .move = moveInitPromote(.sq88, .sq22, .b_bishop),
            .sfen = "lnsgkgsnl/1r5+B1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w B 4",
            .material_value = proDiffPieceValue(.b_horse) + capturedPieceValue(.w_bishop),
        },
        .{
            .move = moveInit(.sq31, .sq22, .w_silver),
            .sfen = "lnsgkg1nl/1r5s1/pppppp1pp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b Bb 5",
            .material_value = 0,
        },
        .{
            .move = moveInitDrop(.sq33, .b_bishop),
            .sfen = "lnsgkg1nl/1r5s1/ppppppBpp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL w b 6",
            .material_value = 0,
        },
        .{
            .move = moveInitDrop(.sq42, .w_bishop),
            .sfen = "lnsgkg1nl/1r3b1s1/ppppppBpp/6p2/9/2P6/PP1PPPPPP/7R1/LNSGKGSNL b - 7",
            .material_value = 0,
        },
    };
    const sfen = DEFAULT_SFEN;
    var st = StateInfo{};
    var pos = Position.fromSfen(sfen, &st);
    var states = [_]StateInfo{StateInfo{}} ** data_list.len;
    for (data_list, 0..) |data, i| {
        pos.doMove(data.move, &states[i]);
        var buf = std.ArrayList(u8).init(tst.allocator);
        defer buf.deinit();
        try pos.toSfen(buf.writer());
        try tst.expectEqualStrings(data.sfen, buf.items);
        try tst.expectEqual(data.material_value, pos.state.material_value);
    }
    for (0..data_list.len) |i| {
        pos.undoMove(data_list[data_list.len - 1 - i].move);
    }
    var buf = std.ArrayList(u8).init(tst.allocator);
    defer buf.deinit();
    try pos.toSfen(buf.writer());
    try tst.expectEqualStrings(sfen, buf.items);
}

test "Position.isPawnDropMate" {
    const data_list = [_]struct {
        sfen: Str,
        to: Square,
        expected: bool,
    }{
        .{ .sfen = PAWN_DROP_MATE_SFEN, .to = .sq12, .expected = true },
        .{ .sfen = "8k/9/7L1/9/9/9/9/9/9 b P 1", .to = .sq12, .expected = false }, // capture by king
        .{ .sfen = "6sk1/5R3/8L/9/9/9/9/9/9 b P 1", .to = .sq22, .expected = false }, // capture by piece
        .{ .sfen = "8k/6+R2/8g/8L/9/9/9/9/9 b P 1", .to = .sq12, .expected = false }, // capture by pinner
        .{ .sfen = "6pkp/5R3/9/9/9/9/9/9/9 b P 1", .to = .sq22, .expected = false }, // escape because of pawn drop
    };
    for (data_list) |data| {
        var st = StateInfo{};
        const pos = Position.fromSfen(data.sfen, &st);
        try tst.expectEqual(data.expected, pos.isPawnDropMate(.black, data.to));
    }
}

test "Position.isMoveEvasive" {
    const data_list = [_]struct {
        sfen: Str,
        move: Move,
        expected: bool,
    }{
        .{ .sfen = EVASIONS_SFEN, .move = moveInitDrop(.sq53, .b_pawn), .expected = true },
        .{ .sfen = EVASIONS_SFEN, .move = moveInitDrop(.sq55, .b_pawn), .expected = false },
        .{ .sfen = EVASIONS_SFEN, .move = moveInit(.sq43, .sq52, .b_gold), .expected = true },
        .{ .sfen = EVASIONS_SFEN, .move = moveInit(.sq43, .sq53, .b_gold), .expected = true },
        .{ .sfen = EVASIONS_SFEN, .move = moveInit(.sq43, .sq42, .b_gold), .expected = false },
        .{ .sfen = EVASIONS_SFEN, .move = moveInit(.sq54, .sq64, .b_king), .expected = true },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInitDrop(.sq45, .b_pawn), .expected = false },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInitDrop(.sq54, .b_pawn), .expected = false },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInit(.sq44, .sq35, .b_horse), .expected = false },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInit(.sq44, .sq53, .b_horse), .expected = false },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInit(.sq55, .sq46, .b_king), .expected = true },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .move = moveInit(.sq55, .sq66, .b_king), .expected = true },
    };
    for (data_list) |data| {
        var st = StateInfo{};
        const pos = Position.fromSfen(data.sfen, &st);
        try tst.expectEqual(data.expected, pos.isMoveEvasive(.black, data.move));
    }
}

test "Position.isMoveSafe" {
    var st = StateInfo{};
    const pos = Position.fromSfen("4ll3/9/4R4/9/4K4/9/9/9/9 b P 1", &st);
    try tst.expectEqual(true, pos.isMoveSafe(.black, moveInitDrop(.sq43, .b_pawn)));
    try tst.expectEqual(false, pos.isMoveSafe(.black, moveInit(.sq53, .sq43, .b_rook)));
    try tst.expectEqual(true, pos.isMoveSafe(.black, moveInit(.sq53, .sq51, .b_rook)));
    try tst.expectEqual(true, pos.isMoveSafe(.black, moveInit(.sq53, .sq52, .b_rook)));
    try tst.expectEqual(true, pos.isMoveSafe(.black, moveInit(.sq53, .sq54, .b_rook)));
    try tst.expectEqual(false, pos.isMoveSafe(.black, moveInit(.sq55, .sq45, .b_king)));
    try tst.expectEqual(true, pos.isMoveSafe(.black, moveInit(.sq55, .sq54, .b_king)));
}

const MAX_MOVES = 600;

const MoveList = struct {
    moves: [MAX_MOVES]Move = undefined,
    len: usize = 0,

    fn append(self: *@This(), m: Move) void {
        self.moves[self.len] = m;
        self.len += 1;
    }

    fn remove(self: *@This(), i: usize) void {
        self.len -= 1;
        self.moves[i] = self.moves[self.len];
    }

    fn swap(self: *@This(), i: usize, j: usize) void {
        std.mem.swap(Move, &self.moves[i], &self.moves[j]);
    }

    pub fn format(self: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (0..self.len) |i| {
            if (i > 0) {
                try writer.writeByte(' ');
            }
            try moveWriteUsi(self.moves[i], writer);
        }
    }
};

const MoveGenType = enum {
    captures,
    captures_all,
    non_captures,
    non_captures_all,
    captures_pro_plus,
    captures_pro_plus_all,
    non_captures_pro_minus,
    non_captures_pro_minus_all,
    recaptures,
    recaptures_all,
    evasions,
    evasions_all,
    non_evasions,
    non_evasions_all,
    legal,
    legal_all,
    checks,
    checks_all,

    fn all(self: @This()) bool {
        return @intFromEnum(self) & 1 != 0;
    }

    fn base(self: @This()) @This() {
        return @enumFromInt(@intFromEnum(self) & 0b11110);
    }
};

fn generateDrops(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const h = pos.hands[@intFromEnum(US)];
    if (h == HAND_EMPTY) {
        return;
    }
    if (handAny(h, .r_pawn)) {
        var to_bb = pawnDropMaskBB(US, pos.colorTypeBB(US, .pawn)) & target;
        const pe = pawnEffectBB(THEM, pos.kingSquare(THEM));
        if (bbAny(to_bb & pe)) {
            if (pos.isPawnDropMate(US, bbPeek(to_bb))) {
                to_bb ^= pe;
            }
        }
        const PAWN = comptime Piece.init(US, .pawn);
        while (bbAny(to_bb)) {
            const to = bbPop(&to_bb);
            mlist.append(moveInitDrop(to, PAWN));
        }
    }
    if (handEmptyExceptPawns(h)) {
        return;
    }
    var drops: [6]Move = undefined;
    var num: usize = 0;
    if (handAny(h, .r_knight)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .knight));
        num += 1;
    }
    const next_to_knight = num;
    if (handAny(h, .r_lance)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .lance));
        num += 1;
    }
    const next_to_lance = num;
    if (handAny(h, .r_silver)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .silver));
        num += 1;
    }
    if (handAny(h, .r_bishop)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .bishop));
        num += 1;
    }
    if (handAny(h, .r_rook)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .rook));
        num += 1;
    }
    if (handAny(h, .r_gold)) {
        drops[num] = comptime moveInitDrop(.sq11, Piece.init(US, .gold));
        num += 1;
    }
    if (next_to_lance == 0) {
        var to_bb = target;
        while (bbAny(to_bb)) {
            const to = bbPop(&to_bb);
            for (0..num) |i| {
                mlist.append(moveSetTo(drops[i], to));
            }
        }
        return;
    }
    var to_bb1 = target & comptime if (US == .black) R1_BB else R9_BB;
    while (bbAny(to_bb1)) {
        const to = bbPop(&to_bb1);
        for (next_to_lance..num) |i| {
            mlist.append(moveSetTo(drops[i], to));
        }
    }
    var to_bb2 = target & comptime if (US == .black) R2_BB else R8_BB;
    while (bbAny(to_bb2)) {
        const to = bbPop(&to_bb2);
        for (next_to_knight..num) |i| {
            mlist.append(moveSetTo(drops[i], to));
        }
    }
    var to_bb3 = target & comptime topRanksBB(THEM, 7);
    while (bbAny(to_bb3)) {
        const to = bbPop(&to_bb3);
        for (0..num) |i| {
            mlist.append(moveSetTo(drops[i], to));
        }
    }
}

test "generateDrops" {
    var st = StateInfo{};
    const pos = Position.fromSfen(DROPS_SFEN, &st);
    var mlist = MoveList{};
    generateDrops(&mlist, .black, &pos, pos.spacesBB());
    try tst.expectEqual(63 + 70 + 61 + 79 * 4, mlist.len);
}

fn generatePawnMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const PC = comptime Piece.init(US, .pawn);
    const TR1 = comptime if (US == .black) Rank.r1 else Rank.r9;
    const to_bb = target & if (US == .black)
        bbShr(pos.colorTypeBB(.black, .pawn), 1)
    else
        bbShl(pos.colorTypeBB(.white, .pawn), 1);
    bbFor(to_bb, &struct {
        mlist: *MoveList,
        fn call(ctx: @This(), to: Square) void {
            const to_r = to.rank();
            const from = to.front(THEM);
            if (to_r.inTop(US, 3)) {
                ctx.mlist.append(moveInitPromote(from, to, PC));
                if (ALL and to_r != TR1) {
                    ctx.mlist.append(moveInit(from, to, PC));
                }
            } else {
                ctx.mlist.append(moveInit(from, to, PC));
            }
        }
    }{ .mlist = mlist });
}

test "generatePawnMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/9/9/9/p8/1p7/9/2p6/9 w - 1", &st);
    var mlist = MoveList{};
    generatePawnMoves(&mlist, true, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(4, mlist.len);
}

fn generateLanceMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const LANCE_TO_BB = comptime if (ALL) topRanksBB(THEM, 8) else topRanksBB(THEM, 7);
    const PC = comptime Piece.init(US, .lance);
    bbFor(pos.colorTypeBB(US, .lance), &struct {
        mlist: *MoveList,
        target: Bitboard,
        occ: Bitboard,
        fn call(ctx: @This(), from: Square) void {
            const to_bb = ctx.target & lanceEffectBB(US, from, ctx.occ);
            bbFor(to_bb & topRanksBB(US, 3), &struct {
                mlist: *MoveList,
                from: Square,
                fn call(ctx2: @This(), to: Square) void {
                    ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                }
            }{ .mlist = ctx.mlist, .from = from });
            bbFor(to_bb & LANCE_TO_BB, &struct {
                mlist: *MoveList,
                from: Square,
                fn call(ctx2: @This(), to: Square) void {
                    ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                }
            }{ .mlist = ctx.mlist, .from = from });
        }
    }{ .mlist = mlist, .target = target, .occ = pos.occBB() });
}

test "generateLanceMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("4l4/9/9/9/4l4/9/9/9/9 w - 1", &st);
    var mlist = MoveList{};
    generateLanceMoves(&mlist, true, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(9, mlist.len);
}

fn generateKnightMoves(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const PC = comptime Piece.init(US, .knight);
    bbFor(pos.colorTypeBB(US, .knight), &struct {
        mlist: *MoveList,
        target: Bitboard,
        fn call(ctx: @This(), from: Square) void {
            bbFor(ctx.target & knightEffectBB(US, from), &struct {
                mlist: *MoveList,
                from: Square,
                fn call(ctx2: @This(), to: Square) void {
                    const to_r = to.rank();
                    if (to_r.inTop(US, 3)) {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                    }
                    if (!to_r.inTop(US, 2)) {
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }
            }{ .mlist = ctx.mlist, .from = from });
        }
    }{ .mlist = mlist, .target = target });
}

test "generateKnightMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/9/9/4n4/4n4/4n4/9/9/9 w - 1", &st);
    var mlist = MoveList{};
    generateKnightMoves(&mlist, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(8, mlist.len);
}

fn generateSilverMoves(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const PC = comptime Piece.init(US, .silver);
    bbFor(pos.colorTypeBB(US, .silver), &struct {
        mlist: *MoveList,
        target: Bitboard,
        fn call(ctx: @This(), from: Square) void {
            const to_bb = ctx.target & silverEffectBB(US, from);
            if (from.rank().inTop(US, 3)) {
                bbFor(to_bb, struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }{ .mlist = ctx.mlist, .from = from });
            } else {
                bbFor(to_bb & topRanksBB(US, 3), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }{ .mlist = ctx.mlist, .from = from });
                bbFor(to_bb & topRanksBB(THEM, 6), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }{ .mlist = ctx.mlist, .from = from });
            }
        }
    }{ .mlist = mlist, .target = target });
}

test "generateSilverMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/9/9/9/9/4s4/4s4/9/9 w - 1", &st);
    var mlist = MoveList{};
    generateSilverMoves(&mlist, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(16, mlist.len);
}

fn generateBishopMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const PC = comptime Piece.init(US, .bishop);
    bbFor(pos.colorTypeBB(US, .bishop), &struct {
        mlist: *MoveList,
        target: Bitboard,
        occ: Bitboard,
        fn call(ctx: @This(), from: Square) void {
            const to_bb = ctx.target & bishopEffectBB(from, ctx.occ);
            if (from.rank().inTop(US, 3)) {
                bbFor(to_bb, &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        if (ALL) {
                            ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                        }
                    }
                }{ .mlist = ctx.mlist, .from = from });
            } else {
                bbFor(to_bb & topRanksBB(US, 3), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        if (ALL) {
                            ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                        }
                    }
                }{ .mlist = ctx.mlist, .from = from });
                bbFor(to_bb & topRanksBB(THEM, 6), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }{ .mlist = ctx.mlist, .from = from });
            }
        }
    }{ .mlist = mlist, .target = target, .occ = pos.occBB() });
}

test "generateBishopMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/1r5b1/9/9/9/9/9/1b5r1/9 w - 1", &st);
    var mlist = MoveList{};
    generateBishopMoves(&mlist, true, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(16 + 9, mlist.len);
}

fn generateRookMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, target: Bitboard) void {
    const THEM = comptime US.turn();
    const PC = comptime Piece.init(US, .rook);
    bbFor(pos.colorTypeBB(US, .rook), &struct {
        mlist: *MoveList,
        target: Bitboard,
        occ: Bitboard,
        fn call(ctx: @This(), from: Square) void {
            const to_bb = ctx.target & rookEffectBB(from, ctx.occ);
            if (from.rank().inTop(US, 3)) {
                bbFor(to_bb, &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        if (ALL) {
                            ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                        }
                    }
                }{ .mlist = ctx.mlist, .from = from });
            } else {
                bbFor(to_bb & topRanksBB(US, 3), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInitPromote(ctx2.from, to, PC));
                        if (ALL) {
                            ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                        }
                    }
                }{ .mlist = ctx.mlist, .from = from });
                bbFor(to_bb & topRanksBB(THEM, 6), &struct {
                    mlist: *MoveList,
                    from: Square,
                    fn call(ctx2: @This(), to: Square) void {
                        ctx2.mlist.append(moveInit(ctx2.from, to, PC));
                    }
                }{ .mlist = ctx.mlist, .from = from });
            }
        }
    }{ .mlist = mlist, .target = target, .occ = pos.occBB() });
}

test "generateRookMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/1r5b1/9/9/9/9/9/1b5r1/9 w - 1", &st);
    var mlist = MoveList{};
    generateRookMoves(&mlist, true, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(24 + 13, mlist.len);
}

fn generateGHDKMovesImpl(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard, type_bb: Bitboard) void {
    bbFor(type_bb & pos.colorBB(US), &struct {
        mlist: *MoveList,
        target: Bitboard,
        occ: Bitboard,
        pos: *const Position,
        fn call(ctx: @This(), from: Square) void {
            const pc = ctx.pos.piece(from);
            bbFor(ctx.target & pieceEffectBB(pc, from, ctx.occ), &struct {
                mlist: *MoveList,
                from: Square,
                pc: Piece,
                fn call(ctx2: @This(), to: Square) void {
                    ctx2.mlist.append(moveInit(ctx2.from, to, ctx2.pc));
                }
            }{ .mlist = ctx.mlist, .from = from, .pc = pc });
        }
    }{ .mlist = mlist, .target = target, .occ = pos.occBB(), .pos = pos });
}

fn generateGHDKMoves(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard) void {
    generateGHDKMovesImpl(mlist, US, pos, target, pos.typeBB(.golds) | pos.typeBB(.hdk));
}

test "generateGHDKMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen("9/9/9/9/1g1+b1+r1k1/9/9/9/9 w - 1", &st);
    var mlist = MoveList{};
    generateGHDKMoves(&mlist, .white, &pos, ~pos.colorBB(.white));
    try tst.expectEqual(@as(usize, 6 + 18 + 14 + 8), mlist.len);
}

fn generateGHDMoves(mlist: *MoveList, comptime US: Color, pos: *const Position, target: Bitboard) void {
    generateGHDKMovesImpl(mlist, US, pos, target, pos.typeBB(.golds) | pos.typeBB(.horse) | pos.typeBB(.dragon));
}

fn generateGeneralMoves(mlist: *MoveList, comptime BGT: MoveGenType, comptime ALL: bool, comptime US: Color, pos: *const Position, recap_sq: Square) void {
    const THEM = comptime US.turn();
    const target = switch (BGT) {
        .captures, .captures_pro_plus => pos.colorBB(THEM),
        .non_captures, .non_captures_pro_minus => pos.spacesBB(),
        .non_evasions => ~pos.colorBB(US),
        .recaptures => squareBB(recap_sq),
        else => unreachable,
    };
    const pawn_target = switch (BGT) {
        .captures_pro_plus => ~pos.colorBB(US) & topRanksBB(US, 3) | pos.colorBB(THEM),
        .non_captures_pro_minus => ~topRanksBB(US, 3) & pos.spacesBB(),
        else => target,
    };
    generatePawnMoves(mlist, ALL, US, pos, pawn_target);
    generateLanceMoves(mlist, ALL, US, pos, target);
    generateKnightMoves(mlist, US, pos, target);
    generateSilverMoves(mlist, US, pos, target);
    generateBishopMoves(mlist, ALL, US, pos, target);
    generateRookMoves(mlist, ALL, US, pos, target);
    generateGHDKMoves(mlist, US, pos, target);
    if (BGT == .non_captures or BGT == .non_captures_pro_minus or BGT == .non_evasions) {
        generateDrops(mlist, US, pos, pos.spacesBB());
    }
}

test "generateGeneralMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen(MATSURI_SFEN, &st);
    var mlist = MoveList{};
    generateGeneralMoves(&mlist, .non_evasions, true, .white, &pos, .none);
    try tst.expectEqual(208, mlist.len);
}

fn generateEvasionMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position) void {
    const PC = comptime Piece.init(US, .king);
    const ksq = pos.kingSquare(US);
    const occ = pos.occBB() ^ squareBB(ksq);
    var attacked_bb = EMPTY_BB;
    var checker_count: usize = 0;
    var checker_sq: Square = .none;
    var checkers_bb = pos.checkersBB();
    while (true) {
        checker_count += 1;
        checker_sq = bbPop(&checkers_bb);
        attacked_bb |= pieceEffectBB(pos.piece(checker_sq), checker_sq, occ);
        if (!bbAny(checkers_bb)) {
            break;
        }
    }
    var bb = ~(pos.colorBB(US) | attacked_bb) & kingEffectBB(ksq);
    while (bbAny(bb)) {
        const to = bbPop(&bb);
        mlist.append(moveInit(ksq, to, PC));
    }
    if (checker_count <= 1) {
        const target1 = betweenBB(checker_sq, ksq);
        const target2 = target1 | squareBB(checker_sq);
        generatePawnMoves(mlist, ALL, US, pos, target2);
        generateLanceMoves(mlist, ALL, US, pos, target2);
        generateKnightMoves(mlist, US, pos, target2);
        generateSilverMoves(mlist, US, pos, target2);
        generateBishopMoves(mlist, ALL, US, pos, target2);
        generateRookMoves(mlist, ALL, US, pos, target2);
        generateGHDMoves(mlist, US, pos, target2);
        generateDrops(mlist, US, pos, target1);
    }
}

test "generateEvasionMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen(EVASIONS_SFEN, &st);
    var mlist = MoveList{};
    generateEvasionMoves(&mlist, true, .black, &pos);
    try tst.expectEqual(9, mlist.len);
}

fn generateDirectCheckMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, from: Square, target: Bitboard, ksq: Square) void {
    const THEM = comptime US.turn();
    const ENEMY_BB = comptime topRanksBB(US, 3);
    const pc = pos.piece(from);
    switch (pc.pieceType()) {
        .pawn => {
            var dst = target & pawnEffectBB(US, from) & goldEffectBB(THEM, ksq) & ENEMY_BB;
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            dst = target & pawnEffectBB(US, from) & pawnEffectBB(THEM, ksq) & topRanksBB(THEM, if (ALL) 8 else 6);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        .lance => {
            const occ = pos.occBB();
            var dst = target & lanceEffectBB(US, from, occ) & goldEffectBB(THEM, ksq) & ENEMY_BB;
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            if (from.file() == ksq.file() and !bbMoreThanOne(betweenBB(from, ksq) & occ)) {
                dst = target & pos.colorBB(THEM) & betweenBB(from, ksq) & topRanksBB(THEM, if (ALL) 8 else 7);
                while (bbAny(dst)) {
                    mlist.append(moveInit(from, bbPop(&dst), pc));
                }
            }
        },
        .knight => {
            var dst = target & knightEffectBB(US, from) & goldEffectBB(THEM, ksq) & ENEMY_BB;
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            dst = target & knightEffectBB(US, from) & knightEffectBB(THEM, ksq) & topRanksBB(THEM, 7);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        .silver => {
            var dst = target & silverEffectBB(US, from) & goldEffectBB(THEM, ksq);
            if (!bbAny(ENEMY_BB & squareBB(from))) {
                dst &= ENEMY_BB;
            }
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            dst = target & silverEffectBB(US, from) & silverEffectBB(THEM, ksq);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        .bishop => {
            const occ = pos.occBB();
            var dst = target & bishopEffectBB(from, occ) & horseEffectBB(ksq, occ);
            if (!bbAny(ENEMY_BB & squareBB(from))) {
                dst &= ENEMY_BB;
            }
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            if (ALL or !from.rank().inTop(US, 3)) {
                dst = target & bishopEffectBB(from, occ) & bishopEffectBB(ksq, occ);
                if (!ALL) {
                    dst &= ~ENEMY_BB;
                }
                while (bbAny(dst)) {
                    mlist.append(moveInit(from, bbPop(&dst), pc));
                }
            }
        },
        .rook => {
            const occ = pos.occBB();
            var dst = target & rookEffectBB(from, occ) & dragonEffectBB(ksq, occ);
            if (!bbAny(ENEMY_BB & squareBB(from))) {
                dst &= ENEMY_BB;
            }
            while (bbAny(dst)) {
                mlist.append(moveInitPromote(from, bbPop(&dst), pc));
            }
            if (ALL or !from.rank().inTop(US, 3)) {
                dst = target & rookEffectBB(from, occ) & rookEffectBB(ksq, occ);
                if (!ALL) {
                    dst &= ~ENEMY_BB;
                }
                while (bbAny(dst)) {
                    mlist.append(moveInit(from, bbPop(&dst), pc));
                }
            }
        },
        .gold, .pro_pawn, .pro_lance, .pro_knight, .pro_silver => {
            var dst = target & goldEffectBB(US, from) & goldEffectBB(THEM, ksq);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        .horse => {
            const occ = pos.occBB();
            var dst = target & horseEffectBB(from, occ) & horseEffectBB(ksq, occ);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        .dragon => {
            const occ = pos.occBB();
            var dst = target & dragonEffectBB(from, occ) & dragonEffectBB(ksq, occ);
            while (bbAny(dst)) {
                mlist.append(moveInit(from, bbPop(&dst), pc));
            }
        },
        else => unreachable,
    }
}

fn generateDiscoveredCheckMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position, from: Square, target: Bitboard) void {
    const THEM = comptime US.turn();
    const ENEMY_BB = comptime topRanksBB(US, 3);
    const pc = pos.piece(from);
    const target2 = pieceEffectBB(pc, from, pos.occBB()) & target;
    switch (pc.pieceType()) {
        .pawn => {
            if (bbAny(target2)) {
                const to = from.front(US);
                if (to.rank().inTop(US, 3)) {
                    mlist.append(moveInitPromote(from, to, pc));
                    if (ALL and !to.rank().inTop(US, 1)) {
                        mlist.append(moveInit(from, to, pc));
                    }
                } else {
                    mlist.append(moveInit(from, to, pc));
                }
            }
        },
        .lance => {
            var bb = target2 & ENEMY_BB;
            while (bbAny(bb)) {
                const to = bbPop(&bb);
                mlist.append(moveInitPromote(from, to, pc));
            }
            bb = target2 & topRanksBB(THEM, if (ALL) 8 else 7);
            while (bbAny(bb)) {
                const to = bbPop(&bb);
                mlist.append(moveInit(from, to, pc));
            }
        },
        .knight => {
            var bb = target2 & ENEMY_BB;
            while (bbAny(bb)) {
                const to = bbPop(&bb);
                mlist.append(moveInitPromote(from, to, pc));
                if (!to.rank().inTop(US, 2)) {
                    mlist.append(moveInit(from, to, pc));
                }
            }
        },
        .silver => {
            if (from.rank().inTop(US, 3)) {
                var bb = target2;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInitPromote(from, to, pc));
                    mlist.append(moveInit(from, to, pc));
                }
            } else {
                var bb = target2 & ENEMY_BB;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInitPromote(from, to, pc));
                    mlist.append(moveInit(from, to, pc));
                }
                bb = target2 & ~ENEMY_BB;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInit(from, to, pc));
                }
            }
        },
        .bishop, .rook => {
            if (from.rank().inTop(US, 3)) {
                var bb = target2;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInitPromote(from, to, pc));
                    if (ALL) {
                        mlist.append(moveInit(from, to, pc));
                    }
                }
            } else {
                var bb = target2 & ENEMY_BB;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInitPromote(from, to, pc));
                    if (ALL) {
                        mlist.append(moveInit(from, to, pc));
                    }
                }
                bb = target2 & ~ENEMY_BB;
                while (bbAny(bb)) {
                    const to = bbPop(&bb);
                    mlist.append(moveInit(from, to, pc));
                }
            }
        },
        .gold, .king, .pro_pawn, .pro_lance, .pro_knight, .pro_silver, .horse, .dragon => {
            var bb = target2;
            while (bbAny(bb)) {
                const to = bbPop(&bb);
                mlist.append(moveInit(from, to, pc));
            }
        },
        else => unreachable,
    }
}

fn generateCheckMoves(mlist: *MoveList, comptime ALL: bool, comptime US: Color, pos: *const Position) void {
    const THEM = comptime US.turn();
    const enemy_ksq = pos.kingSquare(THEM);
    const candidates = ((pos.typeBB(.pawn) & checkCandidateBB(US, .r_pawn, enemy_ksq)) |
        (pos.typeBB(.lance) & checkCandidateBB(US, .r_lance, enemy_ksq)) |
        (pos.typeBB(.knight) & checkCandidateBB(US, .r_knight, enemy_ksq)) |
        (pos.typeBB(.silver) & checkCandidateBB(US, .r_silver, enemy_ksq)) |
        (pos.typeBB(.golds) & checkCandidateBB(US, .r_gold, enemy_ksq)) |
        (pos.typeBB(.bishop) & checkCandidateBB(US, .r_bishop, enemy_ksq)) |
        (pos.typeBB(.rook_dragon)) |
        (pos.typeBB(.horse) & checkCandidateBB(US, .r_rook, enemy_ksq))) &
        pos.colorBB(US);
    const blockers = pos.blockersBB(THEM) & pos.colorBB(US);
    const target = ~pos.colorBB(US);
    var src = blockers;
    while (bbAny(src)) {
        const from = bbPop(&src);
        const pin_line = lineBB(enemy_ksq, from);
        generateDiscoveredCheckMoves(mlist, ALL, US, pos, from, target & ~pin_line);
        if (bbAny(candidates & squareBB(from))) {
            generateDirectCheckMoves(mlist, ALL, US, pos, from, target & pin_line, enemy_ksq);
        }
    }
    src = (candidates | blockers) ^ blockers;
    while (bbAny(src)) {
        generateDirectCheckMoves(mlist, ALL, US, pos, bbPop(&src), target, enemy_ksq);
    }

    const h = pos.hands[@intFromEnum(US)];
    if (h != HAND_EMPTY) {
        const spaces = pos.spacesBB();
        if (handAny(h, .r_pawn)) {
            const dst = spaces & pos.checkSquaresBB(.pawn);
            if (bbAny(dst)) {
                const to = bbPeek(dst);
                if (pos.isPawnDropValid(US, to)) {
                    mlist.append(moveInitDrop(to, Piece.init(US, .pawn)));
                }
            }
        }
        if (!handEmptyExceptPawns(h)) {
            inline for ([_]Piece{
                Piece.init(US, .lance),
                Piece.init(US, .knight),
                Piece.init(US, .silver),
                Piece.init(US, .bishop),
                Piece.init(US, .rook),
                Piece.init(US, .gold),
            }) |PC| {
                if (handAny(h, PC.pieceRaw())) {
                    var dst = spaces & pos.checkSquaresBB(PC.pieceType());
                    while (bbAny(dst)) {
                        mlist.append(moveInitDrop(bbPop(&dst), PC));
                    }
                }
            }
        }
    }

    if (pos.inCheck()) {
        var i = mlist.len;
        while (i > 0) {
            i -= 1;
            if (!pos.isMoveEvasive(US, mlist.moves[i])) {
                _ = mlist.remove(i);
            }
        }
    }
}

fn generateMovesImpl(mlist: *MoveList, comptime MGT: MoveGenType, comptime US: Color, pos: *const Position) void {
    const ALL = comptime MGT.all();
    if (MGT == .legal or MGT == .legal_all) {
        if (pos.inCheck()) {
            generateEvasionMoves(mlist, ALL, US, pos);
        } else {
            generateGeneralMoves(mlist, .non_evasions, ALL, US, pos, .none);
        }
        var i = mlist.len;
        while (i > 0) {
            i -= 1;
            if (!pos.isMoveSafe(US, mlist.moves[i])) {
                mlist.remove(i);
            }
        }
    } else if (MGT == .evasions or MGT == .evasions_all) {
        generateEvasionMoves(mlist, ALL, US, pos);
    } else if (MGT == .checks or MGT == .checks_all) {
        generateCheckMoves(mlist, ALL, US, pos);
        var i = mlist.len;
        while (i > 0) {
            i -= 1;
            if (!pos.isMoveSafe(US, mlist.moves[i])) {
                mlist.remove(i);
            }
        }
    } else {
        generateGeneralMoves(mlist, MGT.base(), ALL, US, pos, .none);
    }
}

fn generateMoves(mlist: *MoveList, comptime MGT: MoveGenType, pos: *const Position) void {
    if (pos.side_to_move == .black) {
        generateMovesImpl(mlist, MGT, .black, pos);
    } else {
        generateMovesImpl(mlist, MGT, .white, pos);
    }
}

test "generateMoves(legal_all)" {
    const data_list = [_]struct {
        sfen: Str,
        len: usize,
    }{
        .{ .sfen = DEFAULT_SFEN, .len = 30 },
        .{ .sfen = MATSURI_SFEN, .len = 207 },
        .{ .sfen = MAX_MOVES_SFEN, .len = 593 },
        .{ .sfen = EVASIONS_SFEN, .len = 6 },
        .{ .sfen = PAWN_DROP_MATE_SFEN, .len = 70 + 10 + 30 },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .len = 2 },
    };
    for (data_list) |data| {
        var st = StateInfo{};
        const pos = Position.fromSfen(data.sfen, &st);
        var mlist = MoveList{};
        generateMoves(&mlist, .legal_all, &pos);
        try tst.expectEqual(data.len, mlist.len);
    }
}

test "generateMoves(evasions)" {
    var st = StateInfo{};
    const pos = Position.fromSfen(EVASIONS_SFEN, &st);
    var mlist = MoveList{};
    generateMoves(&mlist, .evasions, &pos);
    try tst.expectEqual(8, mlist.len);
}

test "generateMoves(captures_pro_plus)" {
    var st = StateInfo{};
    const pos = Position.fromSfen(CAPTURES_SFEN, &st);
    var mlist = MoveList{};
    generateMoves(&mlist, .captures_pro_plus, &pos);
    try tst.expectEqual(4, mlist.len);
}

test "generateMoves(non_captures_pro_minus)" {
    var st = StateInfo{};
    const pos = Position.fromSfen(CAPTURES_SFEN, &st);
    var mlist = MoveList{};
    generateMoves(&mlist, .non_captures_pro_minus, &pos);
    try tst.expectEqual(3, mlist.len);
}

test "generateMoves(checks_all)" {
    const data_list = [_]struct {
        sfen: Str,
        len: usize,
    }{
        .{ .sfen = DEFAULT_SFEN, .len = 0 },
        .{ .sfen = MATSURI_SFEN, .len = 8 },
        .{ .sfen = DROPS_SFEN, .len = 1 + 6 + 2 + 5 + 12 + 16 + 6 },
        .{ .sfen = MAX_CHECKS_SFEN, .len = 91 },
        .{ .sfen = DOUBLE_CHECKED_SFEN, .len = 1 },
        .{ .sfen = "4kl2R/2SP2GB1/4K3r/9/6N2/9/9/9/4L4 b BGSNLP 1", .len = 6 }, // single checked
        .{ .sfen = "4S3R/4kB3/9/5P3/4N4/9/9/9/3L5 b - 1", .len = 8 }, // promote
    };
    for (data_list) |data| {
        var st = StateInfo{};
        const pos = Position.fromSfen(data.sfen, &st);
        var mlist = MoveList{};
        generateMoves(&mlist, .checks_all, &pos);
        try tst.expectEqual(data.len, mlist.len);
    }
}

fn generateRecaptureMoves(mlist: *MoveList, comptime ALL: bool, pos: *const Position, recap_sq: Square) void {
    if (pos.side_to_move == .black) {
        generateGeneralMoves(mlist, .recaptures, ALL, .black, pos, recap_sq);
    } else {
        generateGeneralMoves(mlist, .recaptures, ALL, .white, pos, recap_sq);
    }
}

test "generateRecaptureMoves" {
    var st = StateInfo{};
    const pos = Position.fromSfen(CAPTURES_SFEN, &st);
    var mlist = MoveList{};
    generateRecaptureMoves(&mlist, false, &pos, .sq53);
    try tst.expectEqual(@as(usize, 2), mlist.len);
}

const Depth = i16;
const MAX_DEPTH = 127;

fn perft(allocator: std.mem.Allocator, pos: *Position, depth: Depth) usize {
    var mlist = MoveList{};
    generateMoves(&mlist, .legal_all, pos);
    if (depth < 2) {
        return mlist.len;
    }
    var total: usize = 0;
    var st = StateInfo{};
    for (0..mlist.len) |i| {
        const m = mlist.moves[i];
        pos.doMove(m, &st);
        const count = perft(allocator, pos, depth - 1);
        total += count;
        pos.undoMove(m);
    }
    return total;
}

test "perft(DEFAULT_SFEN)" {
    var st = StateInfo{};
    var pos = Position.fromSfen(DEFAULT_SFEN, &st);
    try tst.expectEqual(@as(usize, 30), perft(tst.allocator, &pos, 1));
    try tst.expectEqual(@as(usize, 900), perft(tst.allocator, &pos, 2));
    try tst.expectEqual(@as(usize, 25470), perft(tst.allocator, &pos, 3));
    try tst.expectEqual(@as(usize, 719731), perft(tst.allocator, &pos, 4));
    // try tst.expectEqual(@as(usize, 19861490), perft(tst.allocator, &pos, 5));
    // try tst.expectEqual(@as(usize, 547581517), perft(tst.allocator, &pos, 6));
}

test "perft(MATSURI_SFEN)" {
    var st = StateInfo{};
    var pos = Position.fromSfen(MATSURI_SFEN, &st);
    try tst.expectEqual(@as(usize, 207), perft(tst.allocator, &pos, 1));
    try tst.expectEqual(@as(usize, 28684), perft(tst.allocator, &pos, 2));
    try tst.expectEqual(@as(usize, 4809015), perft(tst.allocator, &pos, 3));
    // try tst.expectEqual(@as(usize, 516925165), perft(tst.allocator, &pos, 4));
}

const MovePicker = struct {
    mlist: MoveList = .{},
    index: usize = 0,

    fn generate(self: *@This(), pos: *const Position, tt_move: Move) void {
        if (pos.inCheck()) {
            generateMoves(&self.mlist, .evasions, pos);
        } else {
            generateMoves(&self.mlist, .captures_pro_plus, pos);
            generateMoves(&self.mlist, .non_captures_pro_minus, pos);
        }
        if (tt_move != MOVE_NONE) {
            for (0..self.mlist.len) |i| {
                if (self.mlist.moves[i] == tt_move) {
                    self.mlist.swap(0, i);
                    break;
                }
            }
        }
    }

    fn generateRecap(self: *@This(), pos: *const Position, recap_sq: Square) void {
        if (pos.inCheck()) {
            generateMoves(&self.mlist, .evasions, pos);
        } else {
            generateRecaptureMoves(&self.mlist, false, pos, recap_sq);
        }
    }

    fn nextMove(self: *@This()) Move {
        if (self.index < self.mlist.len) {
            const m = self.mlist.moves[self.index];
            self.index += 1;
            return m;
        } else {
            return MOVE_NONE;
        }
    }
};

test "MovePicker.generate" {
    var st = StateInfo{};
    const pos = Position.fromSfen(CAPTURES_SFEN, &st);
    const tt_move = moveInit(.sq64, .sq53, .b_gold);
    var mp = MovePicker{};
    mp.generate(&pos, tt_move);
    try tst.expectEqual(tt_move, mp.nextMove());
    for (1..7) |_| {
        try tst.expect(MOVE_NONE != mp.nextMove());
    }
    try tst.expectEqual(MOVE_NONE, mp.nextMove());
}

test "MovePicker.generateRecap" {
    var st = StateInfo{};
    const pos = Position.fromSfen(CAPTURES_SFEN, &st);
    var mp = MovePicker{};
    mp.generateRecap(&pos, .sq53);
    for (0..2) |_| {
        try tst.expect(MOVE_NONE != mp.nextMove());
    }
    try tst.expectEqual(MOVE_NONE, mp.nextMove());
}

fn evaluate(pos: *const Position) Value {
    var score = pos.state.material_value;
    for (0..Square.N) |sqi| {
        const pc = pos.piece(@enumFromInt(sqi));
        if (pc == .none) {
            continue;
        }
        score -= @divTrunc(pieceValue(pc) * 104, 1024);
    }
    return if (pos.side_to_move == .black) score else -score;
}

test "evaluate" {
    var st = StateInfo{};
    const pos = Position.fromSfen("p8/9/9/9/9/9/9/9/9 w p 1", &st);
    try tst.expectEqual(@as(Value, 81 + 90), evaluate(&pos));
}

extern fn dateNow() i64;

pub fn milliTimestamp() i64 {
    if (builtin.cpu.arch == .wasm32 and builtin.os.tag == .freestanding) {
        return dateNow();
    } else {
        return std.time.milliTimestamp();
    }
}

const RootMove = struct {
    move: Move = MOVE_NONE,
    score: Value = 0,

    fn set(self: *@This(), m: Move, score: Value) void {
        self.move = m;
        self.score = score;
    }

    fn gt(_: void, a: RootMove, b: RootMove) bool {
        return a.score > b.score;
    }
};

const NodeType = enum {
    ROOT,
    PV,
    NON_PV,
};

const Search = struct {
    root_moves: [MAX_MOVES]RootMove = .{RootMove{}} ** MAX_MOVES,
    root_moves_len: usize = 0,
    depth: Depth = 0,
    node_count: u64 = 0,
    time: i64 = 0,
    pv: [MAX_DEPTH * (MAX_DEPTH + 1) / 2]Move = undefined,
    stopped: bool = false,

    fn clear(self: *@This()) void {
        self.root_moves_len = 0;
        self.depth = 0;
        self.node_count = 0;
        self.time = 0;
        @memset(&self.pv, MOVE_NONE);
        self.stopped = false;
    }

    fn appendRootMove(self: *@This(), m: Move) void {
        self.root_moves[self.root_moves_len].set(m, -VALUE_INFINITE);
        self.root_moves_len += 1;
    }

    fn findRootMove(self: @This(), m: Move) ?usize {
        for (0..self.root_moves_len) |i| {
            if (self.root_moves[i].move == m) {
                return i;
            }
        }
        return null;
    }

    fn qsearch(self: *@This(), comptime US: Color, pos: *Position, alpha: Value, beta: Value, depth: Depth, recap_sq: Square) Value {
        const THEM = comptime US.turn();
        var max_alpha = -VALUE_INFINITE;
        if (!pos.inCheck()) {
            max_alpha = alpha;
            const value = evaluate(pos);
            if (value > max_alpha) {
                max_alpha = value;
                if (max_alpha >= beta) {
                    return max_alpha;
                }
            }
            if (depth < -3) {
                return max_alpha;
            }
        }
        var mp = MovePicker{};
        mp.generateRecap(pos, recap_sq);
        while (!self.stopped) {
            const m = mp.nextMove();
            if (m == MOVE_NONE) {
                break;
            }
            if (!pos.isMoveSafe(US, m)) {
                continue;
            }
            var st = StateInfo{};
            pos.doMove(m, &st);
            self.node_count += 1;
            const value = -self.qsearch(THEM, pos, -beta, -max_alpha, depth - 1, moveTo(m));
            pos.undoMove(m);
            if (value > max_alpha) {
                max_alpha = value;
                if (max_alpha >= beta) {
                    break;
                }
            }
        }
        return max_alpha;
    }

    fn plyIndex(ply: usize) usize {
        return (2 * MAX_DEPTH + 1 - ply) * ply / 2;
    }

    fn search(self: *@This(), comptime NT: NodeType, comptime US: Color, pos: *Position, alpha: Value, beta: Value, depth: Depth, ply: usize) Value {
        const NT_ROOT = comptime NT == .ROOT;
        const NT_PV = comptime NT == .PV or NT == .ROOT;
        const THEM = comptime US.turn();
        const ply_index = plyIndex(ply);
        if (NT_PV) {
            self.pv[ply_index] = MOVE_NONE;
        }
        var max_alpha = alpha;
        var move_count: usize = 0;
        const tt_move = if (NT_ROOT) self.root_moves[0].move else MOVE_NONE;
        var mp = MovePicker{};
        mp.generate(pos, tt_move);
        while (!self.stopped) {
            const m = mp.nextMove();
            if (m == MOVE_NONE) {
                break;
            }
            var root_index: usize = 0;
            if (NT_ROOT) {
                if (self.findRootMove(m)) |i| {
                    root_index = i;
                } else {
                    continue;
                }
            }
            if (!pos.isMoveSafe(US, m)) {
                continue;
            }
            var st = StateInfo{};
            pos.doMove(m, &st);
            move_count += 1;
            var value = alpha;
            var full_depth_search = NT == .PV and move_count == 1;
            if (!full_depth_search) {
                const R = 2;
                value = if (depth - R < 1)
                    -self.qsearch(THEM, pos, -beta, -max_alpha, depth - R, moveTo(m))
                else
                    -self.search(.NON_PV, THEM, pos, -(max_alpha + 1), -max_alpha, depth - R, ply + R);
                full_depth_search = value > max_alpha;
            }
            if (full_depth_search) {
                value = if (depth - 1 < 1)
                    -self.qsearch(THEM, pos, -beta, -max_alpha, depth - 1, moveTo(m))
                else
                    -self.search(.PV, THEM, pos, -beta, -max_alpha, depth - 1, ply + 1);
            }
            pos.undoMove(m);
            if (NT_ROOT) {
                if (move_count == 1 or value > max_alpha) {
                    self.root_moves[root_index].score = value;
                } else {
                    self.root_moves[root_index].score = -VALUE_INFINITE;
                }
            }
            if (value > max_alpha) {
                max_alpha = value;
                if (NT_PV) {
                    self.pv[ply_index] = m;
                    const len = MAX_DEPTH - 1 - ply;
                    const ply_index2 = ply_index + 1 + len;
                    @memcpy(self.pv[(ply_index + 1)..ply_index2], self.pv[ply_index2..(ply_index2 + len)]);
                }
                if (max_alpha >= beta) {
                    break;
                }
            }
        }
        self.node_count += move_count;
        return max_alpha;
    }

    fn thinkImpl(self: *@This(), comptime US: Color, pos: *Position, depth: Depth) void {
        self.clear();
        self.time = milliTimestamp();
        defer self.time = milliTimestamp() - self.time;
        var mlist = MoveList{};
        generateMoves(&mlist, .legal_all, pos);
        if (mlist.len == 0) {
            self.appendRootMove(MOVE_NONE);
            return;
        }
        for (0..mlist.len) |i| {
            self.appendRootMove(mlist.moves[i]);
        }
        self.depth = 0;
        while (self.depth < depth) {
            self.depth += 1;
            _ = self.search(.ROOT, US, pos, -VALUE_INFINITE, VALUE_INFINITE, self.depth, 0);
            if (self.stopped) {
                break;
            }
            std.mem.sort(RootMove, self.root_moves[0..self.root_moves_len], {}, RootMove.gt);
        }
    }

    fn think(self: *@This(), pos: *Position, depth: Depth) void {
        if (pos.side_to_move == .black) {
            self.thinkImpl(.black, pos, depth);
        } else {
            self.thinkImpl(.white, pos, depth);
        }
    }

    fn stop(self: *@This()) void {
        self.stopped = true;
    }
};

const MAX_STATES = 1024;

pub const Engine = struct {
    allocator: std.mem.Allocator,
    run_state: enum { ready, running, stopping } = .ready,
    state_infos: [MAX_STATES]StateInfo = .{StateInfo{}} ** MAX_STATES,
    state_count: usize = 1,
    pos: Position = .{},
    search: Search = .{},
    depth_limit: Depth = 3,

    pub fn position(self: *@This(), sfen: Str) void {
        self.pos.setSfen(sfen, &self.state_infos[0]);
        self.state_count = 1;
    }

    pub fn run(self: *@This(), request: Str) !Str {
        var output = std.ArrayList(u8).init(self.allocator);
        const writer = output.writer();
        if (self.run_state == .ready) {
            self.run_state = .running;
            defer self.run_state = .ready;
            var it = std.mem.tokenizeScalar(u8, request, ' ');
            if (it.next()) |cmd| {
                if (strEql(cmd, "usi")) {
                    try writer.print("id name zshogi {s}-{s}-{s}-{s}\n", .{
                        @tagName(builtin.os.tag),
                        @tagName(builtin.cpu.arch),
                        builtin.cpu.model.name,
                        @tagName(builtin.mode),
                    });
                    try writer.print("option name DepthLimit type spin default 3 min 0 max {d}\n", .{MAX_DEPTH});
                    try writer.print("usiok\n", .{});
                } else if (strEql(cmd, "setoption")) {
                    _ = it.next();
                    if (it.next()) |name| {
                        _ = it.next();
                        if (it.next()) |value| {
                            if (strEql(name, "DepthLimit")) {
                                if (std.fmt.parseUnsigned(Depth, value, 10)) |v| {
                                    self.depth_limit = v;
                                } else |_| {}
                            }
                        }
                    }
                } else if (strEql(cmd, "getoption")) {
                    try writer.print("Options[DepthLimit] == {d}\n", .{self.depth_limit});
                } else if (strEql(cmd, "isready")) {
                    try writer.print("readyok\n", .{});
                } else if (strEql(cmd, "usinewgame")) {
                    self.position(DEFAULT_SFEN);
                } else if (strEql(cmd, "matsuri")) {
                    self.position(MATSURI_SFEN);
                } else if (strEql(cmd, "position")) {
                    if (it.next()) |startpos| {
                        var list = std.ArrayList(Str).init(self.allocator);
                        defer list.deinit();
                        if (strEql(startpos, "startpos")) {
                            try list.append(DEFAULT_SFEN);
                            _ = it.next();
                        } else {
                            while (it.next()) |token| {
                                if (strEql(token, "moves")) {
                                    break;
                                }
                                try list.append(token);
                            }
                        }
                        const sfen = try std.mem.join(self.allocator, " ", list.items);
                        defer self.allocator.free(sfen);
                        self.position(sfen);
                        while (it.next()) |token| {
                            const m = self.pos.moveFromUsi(token);
                            self.pos.doMove(m, &self.state_infos[self.state_count]);
                            self.state_count += 1;
                            if (self.state_count >= MAX_STATES) {
                                break;
                            }
                        }
                    }
                } else if (strEql(cmd, "d")) {
                    try writer.print("{}\n", .{self.pos});
                } else if (strEql(cmd, "moves")) {
                    var mlist = MoveList{};
                    generateMoves(&mlist, .legal_all, &self.pos);
                    try writer.print("{}\n", .{mlist});
                } else if (strEql(cmd, "checks")) {
                    var mlist = MoveList{};
                    generateMoves(&mlist, .checks_all, &self.pos);
                    try writer.print("{}\n", .{mlist});
                } else if (strStartsWith(cmd, "go")) {
                    self.search.think(&self.pos, self.depth_limit);
                    const best_root_move = self.search.root_moves[0];
                    try writer.print("info depth {d} score cp {d} nodes {d} nps {d} time {d} pv ", .{
                        self.search.depth,
                        best_root_move.score,
                        self.search.node_count,
                        if (self.search.time > 0) 1000 * self.search.node_count / @abs(self.search.time) else 0,
                        self.search.time,
                    });
                    try moveWriteUsi(best_root_move.move, writer);
                    for (1..MAX_DEPTH) |i| {
                        const m = self.search.pv[i];
                        if (m == MOVE_NONE) {
                            break;
                        }
                        try writer.writeByte(' ');
                        try moveWriteUsi(m, writer);
                    }
                    try writer.print("\nbestmove ", .{});
                    try moveWriteUsi(best_root_move.move, writer);
                    try writer.writeByte('\n');
                }
            }
        }
        return output.toOwnedSlice();
    }

    pub fn stop(self: *@This()) void {
        if (self.run_state == .running) {
            self.run_state = .stopping;
            self.search.stop();
        }
    }
};

test "Engine" {
    const data_list = [_]struct {
        request: Str,
        expected: Str,
    }{
        .{ .request = "usi", .expected = "usiok\n" },
        .{ .request = "isready", .expected = "readyok\n" },
        .{ .request = "usinewgame", .expected = "" },
    };
    var engine = Engine{ .allocator = tst.allocator };
    for (data_list) |data| {
        const response = try engine.run(data.request);
        defer tst.allocator.free(response);
        try tst.expectStringEndsWith(response, data.expected);
    }
}

fn go(engine: *Engine, req: Str, writer: anytype) !void {
    defer engine.allocator.free(req);
    const response = try engine.run(req);
    defer engine.allocator.free(response);
    try writer.writeAll(response);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const reader = std.io.getStdIn().reader();
    const writer = std.io.getStdOut().writer();
    var engine = Engine{ .allocator = allocator };
    engine.position(DEFAULT_SFEN);
    var thread: ?std.Thread = null;
    while (true) {
        var line = std.ArrayList(u8).init(allocator);
        defer line.deinit();
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch |err| switch (err) {
            error.EndOfStream => break,
            else => return err,
        };
        const request = std.mem.trim(u8, line.items, " \r");
        if (strEql(request, "quit")) {
            engine.stop();
            break;
        } else if (strEql(request, "stop")) {
            engine.stop();
        } else if (strStartsWith(request, "go")) {
            const req = try engine.allocator.dupe(u8, request);
            thread = try std.Thread.spawn(.{}, go, .{ &engine, req, writer });
        } else if (request.len > 0) {
            const response = try engine.run(request);
            try writer.writeAll(response);
        }
    }
    if (thread) |t| {
        t.join();
    }
}
