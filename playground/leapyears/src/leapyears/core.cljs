(ns leapyears.core
  (:require [dommy.core :as dom]
            [cljs.reader :refer (read-string)]))

(enable-console-print!)

(def input (dom/sel1 :#year))
(def result (dom/sel1 :#result))

(defn leap?
  [year]
  (or (zero? (js-mod year 400))
      (and (pos? (js-mod year 100))
           (zero? (js-mod year 4)))))

(defn on-change
  [event]
  (let [target (.-target event)
        value (read-string (dom/value target))]
    (if (leap? value)
      (dom/set-html! result "YES")
      (dom/set-html! result "NO"))))

(dom/listen! input :keyup on-change)
