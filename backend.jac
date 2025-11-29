node User {
    has username: str;
    has screenings: list = [];
}

node Screening {
    has tool: str;
    has answers: list;
    has score: int;
    has result: str;
}

walker compute_PHQ9 {
    has answers: list;

    can entry {
        score = sum([int(a) for a in self.answers]);

        result = (
            "Minimal depression" if score <= 4 else
            "Mild depression" if score <= 9 else
            "Moderate depression" if score <= 14 else
            "Moderately severe depression" if score <= 19 else
            "Severe depression"
        );

        here ++> Screening(
            tool="PHQ-9",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"tool": "PHQ-9", "score": score, "result": result};
    }
}

walker compute_GAD7 {
    has answers: list;

    can entry {
        score = sum([int(a) for a in self.answers]);

        result = (
            "Minimal anxiety" if score <= 4 else
            "Mild anxiety" if score <= 9 else
            "Moderate anxiety" if score <= 14 else
            "Severe anxiety"
        );

        here ++> Screening(
            tool="GAD-7",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"tool": "GAD-7", "score": score, "result": result};
    }
}

walker compute_ARM16 {
    has answers: list;

    can entry {
        score = sum([int(a) for a in self.answers]);

        result = (
            "Very Low Resilience" if score <= 32 else
            "Low Resilience" if score <= 48 else
            "Moderate Resilience" if score <= 64 else
            "High Resilience"
        );

        here ++> Screening(
            tool="ARM-16",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"tool": "ARM-16", "score": score, "result": result};
    }
}

walker compute_WERCAP {
    has answers: list;

    can entry {
        score = sum([int(a) for a in self.answers]);

        result = (
            "Low psychosis risk" if score <= 20 else
            "Moderate psychosis risk" if score <= 40 else
            "High psychosis risk"
        );

        here ++> Screening(
            tool="WERCAP",
            answers=self.answers,
            score=score,
            result=result
        );

        report {"tool": "WERCAP", "score": score, "result": result};
    }
}

walker ai_feedback {
    has text: str;

    can entry {
        response = byllm(prompt=f"You are MentaBot. Summary: {self.text}");
        report response;
    }
}

walker get_history {

    can entry {
        visit [-->(?Screening)];
    }

    can exit {
        report here;
    }
}
