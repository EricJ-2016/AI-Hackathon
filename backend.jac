###############################################################
#  BACKEND MODELS (FIXED & COMPILE-READY)
###############################################################

node User {
    has username: str;
    has screenings: list = [];

    # Answers
    has phq9_answers: list;
    has gad7_answers: list;
    has arm16_answers: list;
    has wercap_answers: list;

    # -----------------------------------------
    # PHQ-9
    # -----------------------------------------
    can compute_PHQ9() -> void {
        score = 0;
        for a in self.phq9_answers { score += a; }

        if score <= 4 { result = "Minimal depression"; }
        elif score <= 9 { result = "Mild depression"; }
        elif score <= 14 { result = "Moderate depression"; }
        elif score <= 19 { result = "Moderately severe depression"; }
        else { result = "Severe depression"; }

        screening = new Screening;
        screening.tool = "PHQ-9";
        screening.answers = self.phq9_answers;
        screening.score = score;
        screening.result = result;

        self.screenings.append(screening);
        here -> screening;

        report {"tool": "PHQ-9", "score": score, "result": result};
    }

    # -----------------------------------------
    # GAD-7
    # -----------------------------------------
    can compute_GAD7() -> void {
        score = 0;
        for a in self.gad7_answers { score += a; }

        if score <= 4 { result = "Minimal anxiety"; }
        elif score <= 9 { result = "Mild anxiety"; }
        elif score <= 14 { result = "Moderate anxiety"; }
        else { result = "Severe anxiety"; }

        screening = new Screening;
        screening.tool = "GAD-7";
        screening.answers = self.gad7_answers;
        screening.score = score;
        screening.result = result;

        self.screenings.append(screening);
        here -> screening;

        report {"tool": "GAD-7", "score": score, "result": result};
    }

    # -----------------------------------------
    # ARM-16
    # -----------------------------------------
    can compute_ARM16() -> void {
        score = 0;
        for a in self.arm16_answers { score += a; }

        if score <= 32 { result = "Very Low Resilience"; }
        elif score <= 48 { result = "Low Resilience"; }
        elif score <= 64 { result = "Moderate Resilience"; }
        else { result = "High Resilience"; }

        screening = new Screening;
        screening.tool = "ARM-16";
        screening.answers = self.arm16_answers;
        screening.score = score;
        screening.result = result;

        self.screenings.append(screening);
        here -> screening;

        report {"tool": "ARM-16", "score": score, "result": result};
    }

    # -----------------------------------------
    # WERCAP
    # -----------------------------------------
    can compute_WERCAP() -> void {
        score = 0;
        for a in self.wercap_answers { score += a; }

        if score <= 20 { result = "Low psychosis risk"; }
        elif score <= 40 { result = "Moderate psychosis risk"; }
        else { result = "High psychosis risk"; }

        screening = new Screening;
        screening.tool = "WERCAP";
        screening.answers = self.wercap_answers;
        screening.score = score;
        screening.result = result;

        self.screenings.append(screening);
        here -> screening;

        report {"tool": "WERCAP", "score": score, "result": result};
    }

    # -----------------------------------------
    # GET ALL SCREENINGS
    # -----------------------------------------
    can get_history() -> void {
        report self.screenings;
    }
}

# --------------------------------------------------------------
# SCREENING NODE
# --------------------------------------------------------------
node Screening {
    has tool: str;
    has answers: list;
    has score: int;
    has result: str;
}

# --------------------------------------------------------------
# AI FEEDBACK NODE
# --------------------------------------------------------------
node AI_Feedback {
    has text: str;

    can provide_feedback() -> void {
        response = byllm(prompt=f"You are MentaBot. Summary: {self.text}");
        report response;
    }
}
